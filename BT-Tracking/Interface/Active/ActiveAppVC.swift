//
//  ActiveAppVC.swift
//  eRouska
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import ExposureNotification
import FirebaseAuth
import RxSwift

final class ActiveAppVC: UIViewController {

    private var viewModel = ActiveAppVM()
    private let disposeBag = DisposeBag()
    private var firstAppear = true

    // MARK: - Outlets

    @IBOutlet private weak var exposureBannerView: UIView!
    @IBOutlet private weak var exposureTitleLabel: UILabel!
    @IBOutlet private weak var exposureCloseButton: Button!
    @IBOutlet private weak var exposureMoreInfoButton: Button!

    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var lastUpdateLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!

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

        viewModel.exposureToShow.subscribe(
            onNext: { [weak self] exposure in
                if let exposure = exposure, AppSettings.lastExposureWarningId != exposure.id.uuidString {
                    AppSettings.lastExposureWarningClosed = false
                    AppSettings.lastExposureWarningId = exposure.id.uuidString
                }
                self?.exposureBannerView.isHidden = exposure == nil || AppSettings.lastExposureWarningClosed == true
                self?.view.setNeedsLayout()
            }
        ).disposed(by: disposeBag)

        exposureBannerView.layer.cornerRadius = 9.0
        exposureBannerView.layer.shadowColor = viewModel.cardShadowColor(traitCollection: traitCollection)
        exposureBannerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        exposureBannerView.layer.shadowRadius = 2
        exposureBannerView.layer.shadowOpacity = 1

        AppDelegate.shared.openResultsCallback = { [weak self] in
            self?.riskyEncountersAction()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateViewModel()
        view.setNeedsLayout()
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

        if firstAppear {
            firstAppear = false
            viewModel.backgroundService.performTask()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        exposureBannerView.layer.shadowColor = viewModel.cardShadowColor(traitCollection: traitCollection)
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

        let shareContent: [Any] = [L10n.shareAppMessage(url.absoluteString)]
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
            if viewModel.exposureService.authorizationStatus == .unknown {
                resumeScanning()
            } else {
                openSettings()
            }
        }
    }

    @IBAction private func moreAction(sender: Any?) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: viewModel.menuRiskyEncounters, style: .default, handler: { [weak self] _ in
            self?.riskyEncountersAction()
        }))
        controller.addAction(UIAlertAction(title: L10n.dataListSendTitle, style: .default, handler: { [weak self] _ in
            self?.sendReportsAction()
        }))
        #if !PROD || DEBUG
        controller.addAction(UIAlertAction(title: "", style: .default, handler: nil))
        controller.addAction(UIAlertAction(title: L10n.debug, style: .default, handler: { [weak self] _ in
            self?.debugAction()
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " novinky", style: .default, handler: { [weak self] _ in
            self?.debugShowNews()
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " aktivace", style: .default, handler: { [weak self] _ in
            self?.debugCancelRegistrationAction()
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " rizikového setkání", style: .default, handler: { [weak self] _ in
            self?.debugInsertFakeExposure()
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " zkontrolovat reporty", style: .default, handler: { [weak self] _ in
            self?.debugProcessReports()
        }))
        #endif
        controller.addAction(UIAlertAction(title: L10n.close, style: .cancel))
        controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        present(controller, animated: true)
    }

    @IBAction private func closeExposureBanner(_ sender: Any) {
        AppSettings.lastExposureWarningClosed = true
        exposureBannerView.isHidden = true
    }

    @IBAction private func exposureMoreInfo(_ sender: Any) {
        riskyEncountersAction()
    }

    private func sendReportsAction() {
        if viewModel.state == .disabledExposures {
            showAlert(
                title: L10n.dataListSendErrorDisabledTitle,
                message: L10n.dataListSendErrorDisabledMessage,
                okTitle: L10n.close,
                action: (L10n.turnOn, { [weak self] in self?.openSettings() })
            )
        } else {
            perform(segue: StoryboardSegue.Active.sendReport)
        }
    }

    private func riskyEncountersAction() {
        perform(segue: StoryboardSegue.Active.riskyEncounters)
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

    func updateScanner(activate: Bool, completion: @escaping CallbackVoid) {
        if activate {
            viewModel.exposureService.activate { [weak self] error in
                guard let self = self else { return }

                if let error = error {
                    switch error {
                    case .activationError(let code):
                        self.displayScannerError(error, code: code)
                    default:
                        self.showExposureUnknownError(error, activation: true)
                    }
                    log("ActiveAppVC: failed to active exposures \(error)")
                }
                completion()
            }
        } else {
            viewModel.exposureService.deactivate { [weak self] error in
                if let error = error {
                    self?.showExposureUnknownError(error, activation: false)
                    log("ActiveAppVC: failed to disable exposures \(error)")
                }
                completion()
            }
        }
    }

    func displayScannerError(_ error: ExposureError, code: ENError.Code) {
        switch code {
        case .notAuthorized, .notEnabled:
            break
        case .unsupported:
            viewModel.exposureService.deactivate { [weak self] _ in
                self?.viewModel.exposureService.activate { [weak self] error in
                    guard let error = error else { return }
                    switch error {
                    case .activationError(let code):
                        self?.showExposureUnknownError(error, code: code, activation: true)
                    default:
                        self?.showExposureUnknownError(error, activation: true)
                    }
                }
            }
        case .restricted:
            showAlert(
                title: L10n.exposureActivationRestrictedTitle,
                message: L10n.exposureActivationRestrictedBody,
                okTitle: L10n.exposureActivationRestrictedSettingsAction,
                okHandler: { [weak self] in self?.openSettings() },
                action: (title: L10n.exposureActivationRestrictedCancelAction, handler: nil)
            )
        case .insufficientStorage, .insufficientMemory:
            showExposureStorageError()
        default:
            showExposureUnknownError(error, code: code, activation: true)
        }
    }

    func updateInterface() {
        title = L10n.appName
        navigationItem.backBarButtonItem?.title = L10n.back
        navigationItem.rightBarButtonItems?.last?.title = L10n.shareApp

        navigationController?.tabBarItem.title = L10n.appName
        navigationController?.tabBarItem.image = viewModel.state.tabBarIcon.0
        navigationController?.tabBarItem.selectedImage = viewModel.state.tabBarIcon.1

        imageView.image = viewModel.state.image
        headlineLabel.text = viewModel.state.headline
        headlineLabel.textColor = viewModel.state.color
        titleLabel.text = viewModel.state.title
        textLabel.text = viewModel.state.text

        if viewModel.state == .enabled, let update = AppSettings.lastProcessedDate {
            lastUpdateLabel.text = L10n.activeDataUpdate(viewModel.dateFormatter.string(from: update))
            lastUpdateLabel.isHidden = false
        } else {
            lastUpdateLabel.isHidden = true
        }

        actionButton.setTitle(viewModel.state.actionTitle)
        actionButton.style = viewModel.state == .enabled ? .clear : .filled

        exposureTitleLabel.text = viewModel.exposureTitle
        exposureCloseButton.setTitle(L10n.close)
        exposureMoreInfoButton.setTitle(L10n.activeExposureMoreInfo)
    }

    func checkBackgroundModeIfNeeded() {
        guard !AppSettings.backgroundModeAlertShown, UIApplication.shared.backgroundRefreshStatus == .denied else { return }
        AppSettings.backgroundModeAlertShown = true
        let controller = UIAlertController(
            title: L10n.activeBackgroundModeTitle,
            message: L10n.activeBackgroundModeMessage,
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: L10n.activeBackgroundModeSettings, style: .default, handler: { [weak self] _ in
            self?.openSettings()
        }))
        controller.addAction(UIAlertAction(title: L10n.activeBackgroundModeCancel, style: .default))
        controller.preferredAction = controller.actions.first
        present(controller, animated: true)
    }

    func showExposureStorageError() {
        showAlert(
            title: L10n.exposureActivationStorageTitle,
            message: L10n.exposureActivationStorageBody
        )
    }

    func showExposureUnknownError(_ error: Error, code: ENError.Code = .unknown, activation: Bool) {
        if activation {
            showAlert(
                title: L10n.exposureActivationUnknownTitle,
                message: L10n.exposureActivationUnknownBody("\(code.rawValue)")
            )
        } else {
            showAlert(
                title: L10n.exposureDeactivationUnknownTitle,
                message: L10n.exposureDeactivationUnknownBody("\(code.rawValue)")
            )
        }
    }

    // MARK: - Open external

    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl)
    }

    func openBluetoothSettings() {
        let url: URL?
        if !viewModel.exposureService.isBluetoothOn {
            url = URL(string: UIApplication.openSettingsURLString)
        } else {
            url = URL(string: UIApplication.openSettingsURLString)
        }

        guard let URL = url, UIApplication.shared.canOpenURL(URL) else { return }
        UIApplication.shared.open(URL)
    }

    // MARK: - Debug

    #if !PROD || DEBUG
    func debugAction() {
        let controller = StoryboardScene.Debug.tabBar.instantiate()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    func debugProcessReports() {
        showProgress()

        _ = viewModel.reporter.downloadKeys(lastProcessedFileName: nil) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.viewModel.exposureService.detectExposures(
                    configuration: RemoteValues.exposureConfiguration,
                    URLs: keys.URLs
                ) { [weak self] result in
                    guard let self = self else { return }
                    self.hideProgress()

                    switch result {
                    case .success(let exposures):
                        guard !exposures.isEmpty else {
                            log("EXP: no exposures, skip!")
                            self.showAlert(title: "Exposures", message: "No exposures detected, device is clear.")
                            return
                        }

                        try? ExposureList.add(exposures, detectionDate: Date())

                        var result = ""
                        for exposure in exposures {
                            let signals = exposure.attenuationDurations.map { "\($0)" }
                            result += "EXP: \(self.viewModel.dateFormatter.string(from: exposure.date))" +
                                ", dur: \(exposure.duration), risk \(exposure.totalRiskScore), tran level: \(exposure.transmissionRiskLevel)\n"
                                + "attenuation value: \(exposure.attenuationValue)\n"
                                + "signal attenuations: \(signals.joined(separator: ", "))\n"
                        }

                        if result.isEmpty {
                            result = "None"
                        }

                        log("EXP: \(exposures)")
                        log("EXP: \(result)")
                        self.showAlert(title: "Exposures", message: result)
                    case .failure(let error):
                        self.show(error: error)
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

    func debugInsertFakeExposure() {
        let exposures = [
            Exposure.debugExposure()
        ]

        try? ExposureList.add(exposures, detectionDate: Date())

        let data = ["idToken": KeychainService.token]
        AppDelegate.dependency.functions.httpsCallable("RegisterNotification").call(data) { _, _ in }

        AppSettings.currentDataLastFetchDate = Date()
    }

    func debugShowNews() {
        AppSettings.v2_0NewsLaunched = true
        let controller = StoryboardScene.News.initialScene.instantiate()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    #endif

}
