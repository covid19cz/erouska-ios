//
//  ExposurePermissionVC.swift
//  eRouska
//
//  Created by Tomas Svoboda on 06/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import ExposureNotification
import UserNotifications

final class ExposurePermissionVC: BaseController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasExposureService & HasDiagnosis

    var dependencies: Dependencies!

    // MARK: -

    private let viewModel = ExposurePermissionVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var continueButton: RoundedButtonFilled!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
        setupStrings()
    }

    // MARK: - Action

    @IBAction private func continueAction(_ sender: Any) {
        requestExposurePermission()
    }

}

private extension ExposurePermissionVC {

    func setupStrings() {
        title = L10n.exposureNotificationTitle
        navigationItem.backBarButtonItem?.title = L10n.back
        navigationItem.rightBarButtonItem?.title = L10n.help

        headlineLabel.text = L10n.exposureNotificationHeadline
        bodyLabel.text = L10n.exposureNotificationBody
        continueButton.setTitle(L10n.exposureNotificationContinue)
    }

    // MARK: - Request permission

    func requestExposurePermission() {
        dependencies.exposure.activate { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                log("ExposurePermissionVC: failed to active exposures \(error)")
                switch error {
                case .activationError(let code):
                    switch code {
                    case .notAuthorized:
                        self.showPermissionDeniedAlert(cancelAction: { [weak self] in
                            self?.navigationController?.popViewController(animated: true)
                        })
                    case .unsupported:
                        self.perform(segue: StoryboardSegue.Onboarding.unsupported)
                    case .insufficientStorage, .insufficientMemory:
                        self.showExposureStorageError()
                    case .restricted, .notEnabled:
                        self.showPermissionDeniedAlert(cancelAction: { [weak self] in
                            self?.requestNotificationPermission()
                        })
                    default:
                        self.showUnknownError(error, code: code)
                    }
                default:
                    self.showUnknownError(error)
                }
            } else {
                self.requestNotificationPermission()
            }
        }
    }

    func requestNotificationPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { [weak self] granted, _ in
                DispatchQueue.main.async { [weak self] in
                    if granted {
                        self?.perform(segue: StoryboardSegue.Onboarding.efgsPermission)
                    } else {
                        self?.showPermissionDeniedAlert(cancelAction: { [weak self] in
                            self?.perform(segue: StoryboardSegue.Onboarding.efgsPermission)
                        })
                    }
                }
            }
        )
        UIApplication.shared.registerForRemoteNotifications()
    }

    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl)
    }

    func showExposureStorageError() {
        showAlert(
            title: L10n.exposureActivationStorageTitle,
            message: L10n.exposureActivationStorageBody
        )
    }

    func showUnknownError(_ error: Error, code: ENError.Code = .unknown) {
        showAlert(
            title: L10n.exposureActivationUnknownTitle,
            message: L10n.exposureActivationUnknownBody("\(code.rawValue)"),
            okHandler: { self.requestNotificationPermission() },
            action: (title: L10n.dataSendErrorButton, handler: { [weak self] in
                guard let self = self else { return }

                if self.dependencies.diagnosis.canSendMail {
                    self.dependencies.diagnosis.present(
                        fromController: self,
                        screenName: .exposurePermission,
                        kind: .error(.init(code: "\(code.rawValue)", message: error.localizedDescription))
                    )
                } else if let URL = URL(string: "mailto:info@erouska.cz") {
                    self.openURL(URL: URL)
                }
            })
        )
    }

    func showPermissionDeniedAlert(cancelAction: @escaping CallbackVoid) {
        showAlert(
            title: L10n.exposureActivationRestrictedTitle,
            message: L10n.exposureActivationRestrictedBody,
            okTitle: L10n.exposureActivationRestrictedSettingsAction,
            okHandler: { [weak self] in self?.openSettings() },
            action: (title: L10n.exposureActivationRestrictedCancelAction, handler: cancelAction)
        )
    }

}
