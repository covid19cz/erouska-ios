//
//  ActiveAppVC.swift
// eRouska
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth
import RxSwift

final class ActiveAppVC: UIViewController {

    private var viewModel = ActiveAppVM()
    private let disposeBag = DisposeBag()

    // MARK: - Outlets

    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var footerLabel: UILabel!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var actionButtonWidthConstraint: NSLayoutConstraint!

    @IBOutlet private weak var exposureBannerView: UIView!
    @IBOutlet private weak var exposureTitleLabel: UILabel!
    @IBOutlet private weak var exposureCloseButton: Button!
    @IBOutlet private weak var exposureMoreInfoButton: Button!
    
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

        viewModel.observableState.subscribe(
            onNext: { [weak self] _ in
                self?.updateInterface()
            }
        ).disposed(by: disposeBag)

        exposureBannerView.isHidden = viewModel.exposureToShow == nil

        [cardView, exposureBannerView].forEach {
            $0!.layer.cornerRadius = 9.0
            $0!.layer.shadowColor = viewModel.cardShadowColor(traitCollection: traitCollection)
            $0!.layer.shadowOffset = CGSize(width: 0, height: 1)
            $0!.layer.shadowRadius = 2
            $0!.layer.shadowOpacity = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateViewModel()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
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

    private func pauseScanning() {
        updateScanner(activate: false) { [weak self] in
            AppSettings.state = .paused
            self?.updateViewModel()
        }
    }

    private func resumeScanning() {
        updateScanner(activate: true) { [weak self] in
            AppSettings.state = .enabled
            self?.updateViewModel()
        }
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
        controller.addAction(UIAlertAction(title: Localizable(viewModel.menuRiskyEncounters), style: .default, handler: { [weak self] _ in
            self?.riskyEncountersAction()
        }))
        controller.addAction(UIAlertAction(title: Localizable(viewModel.menuSendReports), style: .default, handler: { [weak self] _ in
            self?.sendReportsAction()
        }))
        #if !PROD
        controller.addAction(UIAlertAction(title: Localizable(viewModel.menuDebug), style: .default, handler: { [weak self] _ in
            self?.debugAction()
        }))
        controller.addAction(UIAlertAction(title: Localizable("Debug: Zkontrolovat reporty"), style: .default, handler: { [weak self] _ in
            self?.debugProcessReports()
        }))
        controller.addAction(UIAlertAction(title: "Debug: " + Localizable(viewModel.menuCancelRegistration), style: .default, handler: { [weak self] _ in
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

    @IBAction private func closeExposureBanner(_ sender: Any) {
        exposureBannerView.isHidden = true
    }

    @IBAction private func exposureMoreInfo(_ sender: Any) {
        riskyEncountersAction()
    }

    private func sendReportsAction() {
        performSegue(withIdentifier: "sendReport", sender: nil)
    }

    private func riskyEncountersAction() {
        performSegue(withIdentifier: "riskyEncounters", sender: nil)
    }

    private func aboutAction() {
        performSegue(withIdentifier: "about", sender: nil)
    }

    // MARK: -
    
    @objc private func applicationDidBecomeActive() {
        updateViewModel()
    }
}

private extension ActiveAppVC {

    func updateViewModel() {
        viewModel.updateStateIfNeeded()
    }

    func updateScanner(activate: Bool, completion: @escaping () -> Void) {
        if activate {
            viewModel.exposureService.activate { [weak self] error in
                if let error = error {
                    self?.show(error: error)
                    log("ActiveAppVC: failed to active exposures \(error)")
                }
                completion()
            }
        } else {
            viewModel.exposureService.deactivate { [weak self] error in
                if let error = error {
                    self?.show(error: error)
                    log("ActiveAppVC: failed to disable exposures \(error)")
                }
                completion()
            }
        }
    }

    func updateInterface() {
        imageView.image = viewModel.state.image
        headlineLabel.localizedText(viewModel.state.headline)
        headlineLabel.textColor = viewModel.state.color
        titleLabel.text = viewModel.state.title
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

        exposureTitleLabel.text = viewModel.exposureTitle
        exposureCloseButton.localizedTitle(viewModel.exposureBannerClose)
        exposureMoreInfoButton.localizedTitle(viewModel.exposureMoreInfo)

        setupStrings()
    }

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)
        navigationItem.rightBarButtonItems?.last?.localizedTitle(viewModel.shareApp)

        navigationController?.tabBarItem.localizedTitle(viewModel.tabTitle)
        navigationController?.tabBarItem.image = viewModel.state.tabBarIcon
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

    // MARK: - Open external
    
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

        guard let URL = url, UIApplication.shared.canOpenURL(URL) else { return }
        UIApplication.shared.open(URL)
    }

    // MARK: - Debug

    func debugAction() {
        let storyboard = UIStoryboard(name: "Debug", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TabBar")
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    func debugProcessReports() {
        showProgress()

        let dateFormat = DateFormatter()
        dateFormat.timeStyle = .short
        dateFormat.dateStyle = .short

        AppDelegate.dependency.reporter.fetchExposureConfiguration { [weak self] result in
            switch result {
            case .success(let configuration):
                _ = AppDelegate.dependency.reporter.downloadKeys { [weak self] result in
                    switch result {
                    case .success(let URLs):
                        AppDelegate.dependency.exposureService.detectExposures(
                            configuration: configuration,
                            URLs: URLs
                        ) { [weak self] result in
                            self?.hideProgress()
                            switch result {
                            case .success(var exposures):
                                exposures.sort { $0.date < $1.date }

                                var result = ""
                                for exposure in exposures {
                                    let signals = exposure.attenuationDurations.map { "\($0)" }
                                    result += "EXP: \(dateFormat.string(from: exposure.date))" +
                                        ", dur: \(exposure.duration), risk \(exposure.totalRiskScore), tran level: \(exposure.transmissionRiskLevel)\n"
                                        + "attenuation value: \(exposure.attenuationValue)\n"
                                        + "signal attenuations: \(signals.joined(separator: ", "))\n"
                                }
                                if result == "" {
                                    result = "None";
                                }

                                log("EXP: \(exposures)")
                                log("EXP: \(result)")
                                self?.showAlert(title: "Exposures", message: result)
                            case .failure(let error):
                                self?.show(error: error)
                            }
                        }
                    case .failure(let error):
                        self?.hideProgress()
                        self?.show(error: error)
                    }
                }
            case .failure(let error):
                self?.hideProgress()
                self?.show(error: error)
            }
        }
    }

    func debugCancelRegistrationAction() {
        AppDelegate.dependency.exposureService.deactivate { _ in
            AppSettings.deleteAllData()
            try? Auth.auth().signOut()
            AppDelegate.shared.updateInterface()
        }
    }

}
