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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: Button!

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        checkForBluetooth()
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
        Ahoj, používám aplikaci Mobilní rouška. Nainstaluj si ji taky a společně pomožme zastavit šíření koronaviru.
        Aplikace sbírá anonymní údaje o telefonech v blízkosti, aby pracovníci hygieny mohli snadněji dohledat potencionálně nakažené.
        Čím víc nás bude, tím lépe to bude fungovat. Aplikaci najdeš na \(url).
        """

        let shareContent: [Any] = [message]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
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
            if advertiser.isRunning != true {
                advertiser.start()
            }

            if scanner.isRunning != true {
                scanner.start()
            }
        case .disabled, .paused:
            if advertiser.isRunning == true {
                advertiser.stop()
            }

            if scanner.isRunning == true {
                scanner.stop()
            }
        }
    }

    func updateInterface() {
        navigationController?.tabBarItem.image = viewModel.state.tabBarIcon

        imageView.image = viewModel.state.image
        headLabel.text = viewModel.state.head
        headLabel.textColor = viewModel.state.color
        titleLabel.text = viewModel.state.title
        textLabel.text = viewModel.state.text.replacingOccurrences(of: "%@", with: Auth.auth().currentUser?.phoneNumber ?? "")
        actionButton.style = viewModel.state.actionStyle
        actionButton.setTitle(viewModel.state.actionTitle, for: .normal)
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

}
