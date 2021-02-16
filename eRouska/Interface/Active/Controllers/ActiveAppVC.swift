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
import FirebaseCrashlytics
import RxSwift

final class ActiveAppVC: UIViewController {

    private let viewModel = ActiveAppVM()
    private let disposeBag = DisposeBag()
    private var firstAppear = true

    private var shadowColor: CGColor {
        UIColor.label.resolvedColor(with: traitCollection).withAlphaComponent(0.2).cgColor
    }

    private let stateSection = ActiveAppSectionView()
    private let riskyEncountersSection = ActiveAppSectionView()
    private let sendReportsSection = ActiveAppSectionView()
    private let efgsSection = ActiveAppSectionView()

    private var dateToShow: Date?
    private var numberOfRiskyEncounters: Int = 0

    // MARK: - Outlets

    @IBOutlet private weak var howItWorksBannerView: ActiveBannerView!
    @IBOutlet private weak var exposureBannerView: ActiveBannerView!
    @IBOutlet private weak var mainStackView: UIStackView!

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
                    AppSettings.lastExposureWarningInfoDisplayed = false
                }
                self?.exposureBannerView.isHidden = exposure == nil || AppSettings.lastExposureWarningClosed == true
                self?.howItWorksBannerView.isHidden = true
                self?.view.setNeedsLayout()
            }
        ).disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.riskyEncounterDateToShow,
            viewModel.riskyEncountersInTimeInterval
        ).subscribe(
            onNext: { [weak self] dateToShow, numberOfRiskyEncounters in
                self?.dateToShow = dateToShow
                self?.numberOfRiskyEncounters = numberOfRiskyEncounters
                self?.updateRiskyEncounters(
                    lastProcessedDate: AppSettings.lastProcessedDate,
                    dateToShow: dateToShow,
                    numberOfRiskyEncounters: numberOfRiskyEncounters
                )
            }
        ).disposed(by: disposeBag)

        AppDelegate.shared.openResultsCallback = { [weak self] in
            self?.riskyEncountersAction()
        }

        stateSection.action = changeScanningAction
        stateSection.isTappable = false

        riskyEncountersSection.isSelectable = true
        riskyEncountersSection.action = riskyEncountersAction

        sendReportsSection.iconImageView.image = Asset.sendData.image
        sendReportsSection.titleLabel.text = L10n.activeSendReportsHead
        sendReportsSection.bodyLabel.text = L10n.activeSendReportsBody
        sendReportsSection.actionButton.setTitle(L10n.activeSendReportsButton)
        sendReportsSection.action = sendReportsAction

        efgsSection.iconImageView.image = Asset.travel.image
        efgsSection.titleLabel.text = viewModel.efgsText
        efgsSection.isSelectable = true
        efgsSection.action = efgsSettingsAction

        [stateSection, riskyEncountersSection, sendReportsSection, efgsSection].forEach(mainStackView.addArrangedSubview)

        howItWorksBannerView.style = .gray
        howItWorksBannerView.isHidden = AppSettings.howItWorksClosed

        #if !PROD
        navigationItem.rightBarButtonItems?.insert(UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(moreAction)
        ), at: 0)
        #endif

        UserDefaults.standard.rx.observe(Bool.self, AppSettings.Keys.efgsEnabled.rawValue)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.updateViewModel()
                }
            ).disposed(by: disposeBag)
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
        [exposureBannerView, stateSection, riskyEncountersSection, sendReportsSection].forEach {
            $0.layer.shadowColor = shadowColor
        }
    }

    // MARK: - Actions

    private func pauseScanning() {
        updateScanner(activate: false) { [weak self] in
            AppSettings.state = .paused
            Events.tapPauseApp.logEvent()
            self?.updateViewModel()
        }
    }

    private func resumeScanning() {
        updateScanner(activate: true) { [weak self] in
            AppSettings.state = .enabled
            Events.tapResumeApp.logEvent()
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

    private func changeScanningAction() {
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

    #if !PROD
    @objc private func moreAction(sender: Any?) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: L10n.debug, style: .default, handler: { [weak self] _ in
            self?.debugAction()
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " novinky", style: .default, handler: { [weak self] _ in
            self?.debugShowNews()
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " aktivace", style: .default, handler: { [weak self] _ in
            self?.debugCancelRegistrationAction()
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " aktualizovat remote config", style: .default, handler: { [weak self] _ in
            self?.debugRemoteConfigUpdate()
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " rizikového setkání", style: .default, handler: { [weak self] _ in
            self?.debugInsertFakeExposure()
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " zobrazit vysledek odeslani", style: .default, handler: { [weak self] _ in
            let controller = UIAlertController(title: "Vysledek", message: nil, preferredStyle: .actionSheet)
            controller.addAction(UIAlertAction(title: "Odeslano", style: .default, handler: { [weak self] _ in
                self?.debugSendResult(kind: .standard)
            }))
            controller.addAction(UIAlertAction(title: "Nema klice", style: .default, handler: { [weak self] _ in
                self?.debugSendResult(kind: .noKeys)
            }))
            controller.addAction(UIAlertAction(title: "Chyba", style: .default, handler: { [weak self] _ in
                self?.debugSendResult(kind: .error("Nakej kod 123", "Naka zprava k chybe"))
            }))
            self?.present(controller, animated: true, completion: nil)
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " zobrazeni nastaveny vyhodnocovani", style: .default, handler: { [weak self] _ in
            self?.showAlert(
                title: "Nastaveni vyhodnoceni",
                message: AppDelegate.shared.remoteConfigString(forKey: .appleExposureConfigurationV2)
            )
        }))
        controller.addAction(UIAlertAction(title: L10n.debug + " zkontrolovat reporty", style: .default, handler: { [weak self] _ in
            self?.debugProcessReports()
        }))
        controller.addAction(UIAlertAction(title: L10n.close, style: .cancel))
        controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        present(controller, animated: true)
    }
    #endif

    @IBAction private func closeHowItWorksBanner(_ sender: Any) {
        AppSettings.howItWorksClosed = true
        howItWorksBannerView.isHidden = true
    }

    @IBAction private func howItWorksMoreInfo(_ sender: Any) {
        perform(segue: StoryboardSegue.Active.howItWorks)
    }

    @IBAction private func closeExposureBanner(_ sender: Any) {
        AppSettings.lastExposureWarningClosed = true
        AppSettings.lastExposureWarningNotDisplayed = false
        exposureBannerView.isHidden = true
        if !AppSettings.howItWorksClosed {
            howItWorksBannerView.isHidden = false
        }
    }

    @IBAction private func exposureMoreInfo(_ sender: Any) {
        riskyEncountersAction()
    }

    private func sendReportsAction() {
        #if DEBUG
        perform(segue: StoryboardSegue.Active.sendReport)
        #else
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
        #endif
    }

    private func riskyEncountersAction() {
        let exposure = ExposureList.last
        let controller: UIViewController

        if exposure == nil {
            controller = StoryboardScene.RiskyEncounters.riskyEncountersNegativeNav.instantiate()
        } else if !AppSettings.lastExposureWarningInfoDisplayed {
            controller = StoryboardScene.RiskyEncounters.newRiskEncounterNav.instantiate()
            AppSettings.lastExposureWarningInfoDisplayed = true
        } else {
            controller = StoryboardScene.RiskyEncounters.riskyEncountersPositiveNav.instantiate()
        }
        present(controller, animated: true, completion: nil)
    }

    private func efgsSettingsAction() {
        perform(segue: StoryboardSegue.Active.traveler)
    }

    // MARK: -

    @objc private func applicationDidBecomeActive() {
        updateViewModel()
        updateRiskyEncounters(lastProcessedDate: AppSettings.lastProcessedDate, dateToShow: dateToShow, numberOfRiskyEncounters: numberOfRiskyEncounters)
        view.setNeedsLayout()
    }
}

private extension ActiveAppVC {

    func updateViewModel() {
        viewModel.updateStateIfNeeded()
        efgsSection.titleLabel.text = viewModel.efgsText
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

        navigationController?.tabBarItem.tag = MainTab.active.rawValue
        navigationController?.tabBarItem.title = L10n.appName
        navigationController?.tabBarItem.image = viewModel.state.tabBarIcon.0
        navigationController?.tabBarItem.selectedImage = viewModel.state.tabBarIcon.1

        stateSection.iconImageView.image = viewModel.state.image
        stateSection.titleLabel.text = viewModel.state.headline
        stateSection.titleLabel.textColor = viewModel.state.color
        stateSection.bodyLabel.text = viewModel.state.text
        stateSection.actionButton.setTitle(viewModel.state.actionTitle)

        howItWorksBannerView.config(with: L10n.howitworksBannerTitle, closeTitle: L10n.howitworksClose, moreInfoTitle: L10n.howitworksBannerMoreInfo)
        exposureBannerView.config(with: viewModel.exposureTitle, closeTitle: L10n.close, moreInfoTitle: L10n.activeExposureMoreInfo)
    }

    func updateRiskyEncounters(lastProcessedDate: Date?, dateToShow: Date?, numberOfRiskyEncounters: Int) {
        let isPositive = dateToShow != nil

        riskyEncountersSection.iconImageView.image = isPositive ? Asset.riskyEncountersPositive.image : Asset.riskyEncountersNegative.image
        riskyEncountersSection.isPositive = isPositive
        if let date = dateToShow {
            riskyEncountersSection.titleLabel.text = L10n.activeRiskyEncounterHeadPositive(numberOfRiskyEncounters)
            let parts: [String] = [
                L10n.activeRiskyEncounterTitlePositive(DateFormatter.baseDateFormatter.string(from: date)),
                [
                    lastProcessedDate.map {
                        L10n.activeRiskyEncounterLastUpdate(DateFormatter.baseDateTimeFormatter.string(from: $0))
                    },
                    L10n.activeRiskyEncounterUpdateInterval
                ].compactMap { $0 }.joined(separator: "\n")
            ]
            riskyEncountersSection.bodyLabel.text = parts.joined(separator: "\n\n")
        } else {
            riskyEncountersSection.titleLabel.text = L10n.activeRiskyEncounterHeadNegative
            riskyEncountersSection.bodyLabel.text = [
                lastProcessedDate.map {
                    L10n.activeRiskyEncounterLastUpdate(DateFormatter.baseDateTimeFormatter.string(from: $0))
                },
                L10n.activeRiskyEncounterUpdateInterval
            ].compactMap { $0 }.joined(separator: "\n")
        }
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
        if AppDelegate.dependency.reporter.isDownloading || AppDelegate.dependency.exposure.detectingExposures {
            showAlert(title: "Stahovani reportu", message: "Bezi na pozadi, pockejte chvilku nez dobehne.")
        } else {
            perform(segue: StoryboardSegue.Active.debugReports)
        }
    }

    func debugCancelRegistrationAction() {
        AppDelegate.dependency.exposure.deactivate { _ in
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

        Auth.auth().currentUser?.getIDToken(completion: { token, error in
            if let token = token {
                let data = ["idToken": token]
                AppDelegate.dependency.functions.httpsCallable("RegisterNotification").call(data) { _, _ in }
            } else if let error = error {
                Crashlytics.crashlytics().record(error: error)
            }
        })

        AppSettings.lastProcessedDate = Date()
    }

    func debugShowNews() {
        AppSettings.v2_0NewsLaunched = true
        let controller = StoryboardScene.News.initialScene.instantiate()
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    func debugSendResult(kind: SendResultVM) {
        let controller = StoryboardScene.SendReports.sendResultVC.instantiate()
        controller.viewModel = kind

        let navController = UINavigationController(rootViewController: controller)
        navController.navigationBar.prefersLargeTitles = true
        present(navController, animated: true, completion: nil)
    }

    func debugRemoteConfigUpdate() {
        AppDelegate.shared.fetchRemoteValues(background: false, ignoreCache: true)
            .subscribe(onSuccess: { _ in
                let configuration = RemoteValues.serverConfiguration
                AppDelegate.dependency.reporter.updateConfiguration(configuration)
                AppDelegate.dependency.verification.updateConfiguration(configuration)
            })
            .disposed(by: disposeBag)
    }

    #endif

}
