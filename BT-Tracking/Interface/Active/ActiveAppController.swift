//
//  ActiveAppController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreBluetooth

final class ActiveAppController: UIViewController {

    private var viewModel = ActiveAppViewModel(bluetoothActive: true)
    private var lastBluetoothState: Bool = true // true enabled

    private let advertiser: BTAdvertising = AppDelegate.shared.advertiser
    private let scanner: BTScannering = AppDelegate.shared.scanner
    
    // MARK: - Outlets

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var firstTipLabel: UILabel!
    @IBOutlet weak var secondTipLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: Button!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var actionButtonWidthConstraint: NSLayoutConstraint!
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = AppDelegate.shared.scannerStore // start scanner store

        AppDelegate.shared.scanner.didUpdateState = { [weak self] state in
            guard let self = self else { return }
            if state == .poweredOff, self.viewModel.state != .disabled {
                self.checkForBluetooth()
            } else if state == .poweredOn, self.viewModel.state == .disabled {
                self.checkForBluetooth()
            }
        }

        checkForBluetooth()

        updateScanner()
        updateInterface()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutCardView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        checkForBluetooth()
        checkBackgroundModeIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Actions

    func pauseScanning() {
        AppSettings.state = .paused
        updateViewModel()
    }

    func resumeScanning() {
        AppSettings.state = .enabled
        updateViewModel()
    }

    @IBAction private func shareAppAction() {
        guard let url = URL(string: RemoteValues.shareAppDynamicLink) else { return }

        let message = """
        Ahoj, používám aplikaci eRouška. Nainstaluj si ji taky a společně pomozme zastavit šíření koronaviru. Aplikace sbírá anonymní údaje o telefonech v blízkosti, aby pracovníci hygieny mohli snadněji dohledat potencionálně nakažené. Čím víc nás bude, tím lépe to bude fungovat. Aplikaci najdeš na \(url).
        """

        let shareContent: [Any] = [message]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.last ?? navigationItem.rightBarButtonItem
        
        present(activityViewController, animated: true, completion: nil)
    }

    @IBAction private func changeScanningAction() {
        switch viewModel.state {
        case .enabled:
            AppSettings.state = .paused
        case .paused:
            AppSettings.state = .enabled
        case .disabled:
            let url: URL?
            if AppDelegate.shared.scanner.state == .poweredOff {
                url = URL(string: "App-Prefs::root=Settings&path=Bluetooth")
            } else {
                url = URL(string: UIApplication.openSettingsURLString)
            }

            guard let URL = url else { return }
            UIApplication.shared.open(URL)
            return
        }
        updateViewModel()
    }

    @IBAction private func moreAction(sender: Any?) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Zrušit registraci", style: .default, handler: { [weak self] _ in
            self?.performSegue(withIdentifier: "unregisterUser", sender: nil)
        }))
        controller.addAction(UIAlertAction(title: "Debug", style: .default, handler: { [weak self] _ in
            self?.performSegue(withIdentifier: "debug", sender: nil)
        }))
        controller.addAction(UIAlertAction(title: "O aplikaci", style: .default, handler: { [weak self] _ in
            guard let url = URL(string: RemoteValues.aboutLink) else { return }
            self?.openURL(URL: url)
        }))
        controller.addAction(UIAlertAction(title: "Zavřít", style: .cancel, handler: nil))
        controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        present(controller, animated: true, completion: nil)
    }

    // MARK: -
    
    @objc private func applicationDidBecomeActive() {
        checkForBluetooth()
    }

}

private extension ActiveAppController {

    func updateViewModel() {
        viewModel = ActiveAppViewModel(bluetoothActive: lastBluetoothState)

        updateScanner()
        updateInterface()
    }

    func updateScanner() {
        switch viewModel.state {
        case .enabled:
            advertiser.start()
            scanner.start()
        case .disabled, .paused:
            advertiser.stop()
            scanner.stop()
        }
    }

    func updateInterface() {
        navigationController?.tabBarItem.image = viewModel.state.tabBarIcon

        guard mainStackView.arrangedSubviews.count >= 4 else { return }
        let isHiddenArrangedSubview = viewModel.state != .enabled
        mainStackView.arrangedSubviews[2].isHidden = isHiddenArrangedSubview
        mainStackView.arrangedSubviews[3].isHidden = isHiddenArrangedSubview
        mainStackView.arrangedSubviews[4].isHidden = isHiddenArrangedSubview
        imageView.image = viewModel.state.image
        headLabel.text = viewModel.state.head
        headLabel.textColor = viewModel.state.color
        titleLabel.text = viewModel.state.title
        tipsLabel.text = viewModel.state.tips
        firstTipLabel.text = viewModel.state.firstTip
        secondTipLabel.text = viewModel.state.secondTip
        textLabel.text = viewModel.state.text.replacingOccurrences(of: "%@", with: Auth.auth().currentUser?.phoneNumber?.phoneFormatted ?? "")
        actionButton.setTitle(viewModel.state.actionTitle, for: .normal)
        // Apply element size fix for iPhone SE size screens only
        cardView.layoutIfNeeded()
        if cardView.bounds.width <= 288 {
            actionButtonWidthConstraint.constant = viewModel.state == .enabled ? 120 : 100
            actionButton.layoutIfNeeded()
        }
    }

    func checkForBluetooth() {
        var state: Bool
        if #available(iOS 13.0, *) {
            state = AppDelegate.shared.advertiser.authorization == .allowedAlways
        } else {
            state = CBPeripheralManager.authorizationStatus() == .authorized
        }

        if AppDelegate.shared.scanner.state == .poweredOff {
            state = false
        }

        guard lastBluetoothState != state else { return }
        lastBluetoothState = state
        updateViewModel()
    }

    func checkBackgroundModeIfNeeded() {
        guard !AppSettings.backgroundModeAlertShown, UIApplication.shared.backgroundRefreshStatus == .denied else { return }
        AppSettings.backgroundModeAlertShown = true
        let controller = UIAlertController(
            title: "Aktualizace na pozadí",
            message: "eRouška se potřebuje sama spustit i na pozadí, například po restartování telefonu, abyste na to nemuseli myslet vy.\n\nPovolte možnost 'Aktualizace na pozadí' v nastavení aplikace.",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Upravit nastavení", style: .default, handler: { [weak self] _ in
            self?.openSettings()
        }))
        controller.addAction(UIAlertAction(title: "Zavřít", style: .default, handler: nil))
        controller.preferredAction = controller.actions.first
        present(controller, animated: true)
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl)
    }
    
    private func layoutCardView() {
        cardView.layoutIfNeeded()
        // Card shape
        cardView.layer.cornerRadius = 9.0
        // Shadow
        let shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 9.0)
        if #available(iOS 13.0, *) {
            cardView.layer.shadowColor = UIColor.label.withAlphaComponent(0.25).cgColor
        } else {
            cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        }
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cardView.layer.shadowRadius = 2.0
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.shadowPath = shadowPath.cgPath
    }
}
