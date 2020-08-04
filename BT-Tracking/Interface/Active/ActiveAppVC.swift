//
//  ActiveAppVC.swift
// eRouska
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth

final class ActiveAppVC: UIViewController {

    private var viewModel = ActiveAppVM(bluetoothActive: true)
    
    // MARK: - Outlets

    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tipsLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var firstTipLabel: UILabel!
    @IBOutlet private weak var secondTipLabel: UILabel!
    @IBOutlet private var tipsViews: [UIView]!
    @IBOutlet private weak var footerLabel: UILabel!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var actionButtonWidthConstraint: NSLayoutConstraint!
    
    // MARK: -

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
        updateScanner()
        updateInterface()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutCardView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateInterface()
        layoutCardView()
        checkForBluetooth()
        checkForExposureService()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        cardView.layer.shadowColor = viewModel.cardShadowColor(traitCollection: traitCollection)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        checkBackgroundModeIfNeeded()
    }

    // MARK: - Actions

    func pauseScanning() {
        AppSettings.state = .paused
        updateViewModel()
    }

    private func resumeScanning() {
        AppSettings.state = .enabled
        updateViewModel()
    }

    @IBAction private func shareAppAction() {
        guard let url = URL(string: RemoteValues.shareAppDynamicLink) else { return }

        let message = String(format: Localizable(viewModel.shareAppMessage), url.absoluteString)
        let shareContent: [Any] = [message]
        let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.last ?? navigationItem.rightBarButtonItem
        
        present(activityViewController, animated: true)
    }

    @IBAction private func changeScanningAction() {
        switch viewModel.state {
        case .enabled:
            pauseScanning()
        case .paused:
            resumeScanning()
        case .disabledBluetooth:
            openBluetoothSettings()
        case .disabledExposures:
            openSettings()
        }
    }

    @IBAction private func moreAction(sender: Any?) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        #if !PROD
        controller.addAction(UIAlertAction(title: Localizable(viewModel.menuDebug), style: .default, handler: { [weak self] _ in
            self?.debugAction()
        }))
        controller.addAction(UIAlertAction(title: Localizable(viewModel.menuCancelRegistration), style: .default, handler: { [weak self] _ in
            self?.debugCancelRegistrationAction()
        }))
        #endif
        controller.addAction(UIAlertAction(title: Localizable(viewModel.menuAbout), style: .default, handler: { [weak self] _ in
            self?.aboutAction()
        }))
        controller.addAction(UIAlertAction(title: Localizable(viewModel.menuCancel), style: .cancel))
        controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        present(controller, animated: true)
    }

    private func debugAction() {
        let storyboard = UIStoryboard(name: "Debug", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TabBar")
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    private func debugCancelRegistrationAction() {
        AppDelegate.dependency.exposureService.deactivate { _ in
            AppSettings.deleteAllData()
            try? Auth.auth().signOut()
            AppDelegate.shared.updateInterface()
        }
    }

    private func aboutAction() {
        let storyboard = UIStoryboard(name: "Help", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "About")
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: -
    
    @objc private func applicationDidBecomeActive() {
        checkForBluetooth()
        checkForExposureService()
        if viewModel.state == .disabledExposures {
            updateScanner()
        }
    }
}

private extension ActiveAppVC {

    func updateViewModel(updateScanner: Bool = true) {
        viewModel = ActiveAppVM(bluetoothActive: viewModel.lastBluetoothState)

        if updateScanner {
            self.updateScanner()
        }
        updateInterface()
        setupStrings()
    }

    func updateScanner() {
        switch viewModel.state {
        case .enabled, .disabledBluetooth, .disabledExposures:
            viewModel.exposureService.activate { [weak self] error in
                self?.checkForExposureService()

                guard let error = error else { return }
                log("ActiveAppVC: failed to active exposures \(error)")
            }
        case .paused:
            viewModel.exposureService.deactivate { [weak self] error in
                self?.checkForExposureService()

                guard let error = error else { return }
                log("ActiveAppVC: failed to disable exposures \(error)")
            }
        }
    }

    func updateInterface() {
        let isActive = viewModel.state != .enabled
        tipsViews.forEach { $0.isHidden = isActive }
        imageView.image = viewModel.state.image
        headlineLabel.localizedText(viewModel.state.headline)
        headlineLabel.textColor = viewModel.state.color
        titleLabel.text = viewModel.state.title
        tipsLabel.localizedText(viewModel.tips)
        firstTipLabel.localizedText(viewModel.firstTip)
        secondTipLabel.localizedText(viewModel.secondTip)
        if let footer = viewModel.state.footer {
            footerLabel.localizedText(footer, values: Auth.auth().currentUser?.phoneNumber?.phoneFormatted ?? "")
        } else {
            footerLabel.text = nil
        }
        actionButton.localizedTitle(viewModel.state.actionTitle)

        // Apply element size fix for iPhone SE size screens only
        cardView.layoutIfNeeded()
        if cardView.bounds.width <= 288 {
            actionButtonWidthConstraint.constant = viewModel.state == .enabled ? 110 : 100
            actionButton.layoutIfNeeded()
        }
    }

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)
        navigationItem.rightBarButtonItems?.last?.localizedTitle(viewModel.shareApp)

        navigationController?.tabBarItem.localizedTitle(viewModel.tabTitle)
        navigationController?.tabBarItem.image = viewModel.state.tabBarIcon
    }

    func layoutCardView() {
        cardView.layoutIfNeeded()

        // Card shape
        cardView.layer.cornerRadius = 9.0

        // Card shadow
        cardView.layer.shadowColor = viewModel.cardShadowColor(traitCollection: traitCollection)
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowRadius = 2
        cardView.layer.shadowOpacity = 1
    }

    func checkForBluetooth() {
        let state = viewModel.exposureService.isBluetoothOn
        guard viewModel.lastBluetoothState != state else { return }
        viewModel.lastBluetoothState = state
        updateViewModel()
    }

    func checkForExposureService() {
        guard viewModel.lastBluetoothState != false else { return }

        let state: ActiveAppVM.State
        switch AppDelegate.dependency.exposureService.status {
        case .active, .paused:
            state = .enabled
        case .disabled:
            state = .paused
        case .bluetoothOff:
            state = .disabledBluetooth
        case .restricted:
            state = .disabledExposures
        case .unknown:
            state = AppSettings.state ?? .enabled
        @unknown default:
            return
        }

        guard viewModel.state != state else { return }
        AppSettings.state = state
        updateViewModel(updateScanner: false)
    }

    func checkBackgroundModeIfNeeded() {
        guard !AppSettings.backgroundModeAlertShown, UIApplication.shared.backgroundRefreshStatus == .denied else { return }
        AppSettings.backgroundModeAlertShown = true
        let controller = UIAlertController(
            title: Localizable(viewModel.backgroundModeTitle),
            message: Localizable(viewModel.backgroundModeMessage),
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: Localizable(viewModel.backgroundModeAction), style: .default, handler: { [weak self] _ in
            self?.openSettings()
        }))
        controller.addAction(UIAlertAction(title: Localizable(viewModel.backgroundModeCancel), style: .default))
        controller.preferredAction = controller.actions.first
        present(controller, animated: true)
    }
    
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl)
    }

    func openBluetoothSettings() {
        let url: URL?
        if !viewModel.exposureService.isBluetoothOn {
            url = URL(string: "App-Prefs::root=Settings&path=Bluetooth")
        } else {
            url = URL(string: UIApplication.openSettingsURLString)
        }

        guard let URL = url else { return }
        UIApplication.shared.open(URL)
    }
}
