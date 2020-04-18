//
//  RegistrationCoordinator.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 16/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications
import FirebaseAuth
import DeviceKit

protocol RegistrationCoordinatorDelegate: AnyObject {
    func coordinatorDidFinishRegistration(_ coordinator: RegistrationCoordinator)
}

final class RegistrationCoordinator: Coordinator {
    // MARK: - Public Properties
    weak var delegate: RegistrationCoordinatorDelegate?

    // MARK: - Private Properties
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let userNotificationCenter: UNUserNotificationCenter
    private let authorizationService: AuthorizationService
    private let storyboard = UIStoryboard(name: "Signup", bundle: nil)

    private var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

    private var phoneNumber: String?
    private var verificationId: String?

    init(
        window: UIWindow,
        authorizationService: AuthorizationService,
        navigationController: UINavigationController = UINavigationController(),
        userNotificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    ) {
        self.window = window
        self.authorizationService = authorizationService
        self.navigationController = navigationController
        self.userNotificationCenter = userNotificationCenter

        navigationController.navigationBar.prefersLargeTitles = true
    }

    func start() {
        setupWindow()
        showIntroScreen()
    }

     private func setupWindow() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

// MARK: - Show Screens

private extension RegistrationCoordinator {
    func showIntroScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "IntroController") as! IntroController
        viewController.delegate = self

        navigationController.pushViewController(viewController, animated: false)
    }

    func showHelpScreen() {
        navigationController.pushViewController(HelpVC(), animated: true)
    }

    func showBluetoothScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "BluetoothActivationController") as! BluetoothActivationController
        viewController.delegate = self

        navigationController.pushViewController(viewController, animated: true)
    }

    func showPhoneNumberScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "PhoneNumberController") as! PhoneNumberController
        viewController.delegate = self

        navigationController.pushViewController(viewController, animated: true)
    }

    func showVerificationCodeScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "VerificationCodeController") as! VerificationCodeController
        viewController.phoneNumber = phoneNumber
        viewController.delegate = self

        navigationController.pushViewController(viewController, animated: true)
    }

    func showNotificationsScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationPermissionController") as! NotificationPermissionController
        viewController.delegate = self

        navigationController.pushViewController(viewController, animated: true)
    }

    func showNextScreenBasedOnNotificationSettings() {
        userNotificationCenter.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    self.showNotificationsScreen()
                } else {
                    self.showPhoneNumberScreen()
                }
            }
        }
    }
}

// MARK: - Private Methods

private extension RegistrationCoordinator {
    func cleanup() {
        try? authorizationService.signOut()
        UserDefaults.resetStandardUserDefaults()
    }
}

// MARK: - IntroControllerDelegate

extension RegistrationCoordinator: IntroControllerDelegate {
    func controllerDidTapContinue(_ controller: IntroController) {
        guard bluetoothAuthorized else {
            showBluetoothScreen()
            return
        }

        showNextScreenBasedOnNotificationSettings()
    }

    func controllerDidTapHelp(_ controller: IntroController) {
        showHelpScreen()
    }

    func controllerDidTapAudit(_ controller: IntroController) {
        guard let url = URL(string: RemoteValues.proclamationLink) else { return }
        controller.openURL(URL: url)
    }
}

// MARK: - BluetoothActivationControllerDelegate

extension RegistrationCoordinator: BluetoothActivationControllerDelegate {
    func controllerDidSetBluetooth(_ controller: BluetoothActivationController) {
        showNextScreenBasedOnNotificationSettings()
    }

    func controllerDidTapHelp(_ controller: BluetoothActivationController) {
        showHelpScreen()
    }
}

// MARK: - NotificationPermissionControllerDelegate

extension RegistrationCoordinator: NotificationPermissionControllerDelegate {
    func controllerDidTapContinue(_ controller: NotificationPermissionController) {
        userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.showPhoneNumberScreen()
            }
        }

        UIApplication.shared.registerForRemoteNotifications()
    }

    func controllerDidTapHelp(_ controller: NotificationPermissionController) {
        showHelpScreen()
    }
}

// MARK: - PhoneNumberControllerDelegate

extension RegistrationCoordinator: PhoneNumberControllerDelegate {
    func controllerDidTapHelp(_ controller: PhoneNumberController) {
        showHelpScreen()
    }

    func controllerDidTapPrivacy(_ controller: PhoneNumberController) {
        guard let url = URL(string: RemoteValues.termsAndConditionsLink) else { return }
        controller.openURL(URL: url)
    }

    func controller(_ controller: PhoneNumberController, didTapContinueWithPhoneNumber phoneNumber: String) {
        self.phoneNumber = phoneNumber

        controller.showProgress()

        authorizationService.verifyPhoneNumber(phoneNumber) { [weak self, weak controller] result in
            guard let self = self, let controller = controller else { return }

            controller.hideProgress()

            switch result {
            case let .success(verificationId):
                self.showVerificationCodeScreen()
                self.verificationId = verificationId
            case .failure(.limitExceeded):
                controller.showError(
                    title: "Telefonní číslo jsme dočasně zablokovali",
                    message: "Několikrát jste zkusili neúspěšně ověřit telefonní číslo. Za chvíli to zkuste znovu."
                )
            case .failure(.general):
                controller.showError(
                    title: "Nepodařilo se nám ověřit telefonní číslo",
                    message: "Zkontrolujte připojení k internetu a zkuste to znovu"
                )
            }
        }
    }
}

// MARK: - VerificationCodeControllerDelegate

extension RegistrationCoordinator: VerificationCodeControllerDelegate {
    func controllerDidTapHelp(_ controller: VerificationCodeController) {
        showHelpScreen()
    }

    func controllerDidTapRetry(_ controller: VerificationCodeController) {
        navigationController.popViewController(animated: true)
    }

    func controller(_ controller: VerificationCodeController, didTapVerifyWithCode code: String) {
        guard let verificationId = verificationId else {
            controller.handleError(.general)
            return
        }

        controller.showProgress()

        authorizationService.verifyCode(code, withVerificationId: verificationId) { [weak self, weak controller] result in

            guard let self = self, let controller = controller else { return }
            controller.hideProgress()

            switch result {
            case .success:
                self.registerBuid(at: controller)
            case let .failure(error):
                controller.handleError(error)
            }
        }
    }

    private func registerBuid(at controller: UIViewController) {
        let data: [String: Any] = [
            "platform": "iOS",
            "platformVersion": UIDevice.current.systemVersion,
            "manufacturer": "Apple",
            "model": Device.current.description,
            "locale": "\(Locale.current.languageCode ?? "cs")_\(Locale.current.regionCode ?? "CZ")",
            "pushRegistrationToken": AppDelegate.shared.deviceToken?.hexEncodedString ?? "xyz"
        ]

        controller.showProgress()

        AppDelegate.shared.functions.httpsCallable("registerBuid").call(data) { [weak self, weak controller] result, error in
            guard let self = self, let controller = controller else { return }
            controller.hideProgress()

            if let error = error as NSError? {
                log("RegistrationCoordinator: registerBuid error: \(error.localizedDescription), code: \(error.code)")

                self.cleanup()
                self.navigationController.popViewController(animated: true)
                self.navigationController.topViewController?.show(error: error, title: "Chyba při aktivaci")

                return
            }

            guard
                let result = result?.data as? [String: Any],
                let BUID = result["buid"] as? String,
                let TUIDs = result["tuids"] as? [String]
            else {
                log("RegistrationCoordinator: registerBuid wrong data")
                self.cleanup()
                controller.showError(message: "Chyba při aktivaci")
                return
            }

            log("RegistrationCoordinator: registerBuid success")

            KeychainService.BUID = BUID
            KeychainService.TUIDs = TUIDs

            self.delegate?.coordinatorDidFinishRegistration(self)
        }
    }
}
