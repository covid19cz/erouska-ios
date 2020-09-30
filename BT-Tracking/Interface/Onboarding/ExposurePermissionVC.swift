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

final class ExposurePermissionVC: UIViewController {

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
        navigationItem.localizedTitle(.exposure_notification_title)
        navigationItem.backBarButtonItem?.localizedTitle(.back)
        navigationItem.rightBarButtonItem?.localizedTitle(.help)

        headlineLabel.localizedText(.exposure_notification_headline)
        bodyLabel.localizedText(.exposure_notification_body)
        continueButton.localizedTitle(.exposure_notification_continue)
    }

    // MARK: - Request permission

    func requestExposurePermission() {
        viewModel.exposureService.activate { [weak self] error in
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
                        self.performSegue(withIdentifier: "unsupported", sender: nil)
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
                        self?.performSegue(withIdentifier: "privacy", sender: nil)
                    } else {
                        self?.showPermissionDeniedAlert(cancelAction: { [weak self] in
                            self?.performSegue(withIdentifier: "privacy", sender: nil)
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
        showAlert(title: .exposure_activation_storage_title, message: .exposure_activation_storage_body)
    }

    func showUnknownError(_ error: Error, code: ENError.Code = .unknown) {
        showAlert(
            title: Localization.exposure_activation_unknown_title.localized,
            message: String(format: Localization.exposure_activation_unknown_body.rawValue, arguments: ["\(code.rawValue)"]),
            okHandler: { self.requestNotificationPermission() }
        )
    }

    func showPermissionDeniedAlert(cancelAction: @escaping () -> Void) {
        showAlert(
            title: .exposure_activation_restricted_title,
            message: .exposure_activation_restricted_body,
            okTitle: .exposure_activation_restricted_settings_action,
            okHandler: { [weak self] in self?.openSettings() },
            action: (title: .exposure_activation_restricted_cancel_action, handler: cancelAction)
        )
    }

}
