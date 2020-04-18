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

final class RegistrationCoordinator: Coordinator {
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
        showWelcomeScreen()
    }

     private func setupWindow() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

// MARK: - Show Screens

private extension RegistrationCoordinator {
    func showWelcomeScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "FirstActivationController") as! FirstActivationController
        viewController.delegate = self

        navigationController.pushViewController(viewController, animated: false)
    }

    func showHelpScreen() {
        navigationController.pushViewController(HelpVC(), animated: true)
    }

    func showBluetoothScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "BluetoothActivationController") as! BluetoothActivationController

        navigationController.pushViewController(viewController, animated: true)
    }

    func showPhoneNumberScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "PhoneNumberController") as! PhoneNumberController

        navigationController.pushViewController(viewController, animated: true)
    }

    func showVerificationCodeScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "CompleteActivationController") as! CompleteActivationController

        navigationController.pushViewController(viewController, animated: true)
    }

    func showNotificationsScreen() {
        let viewController = storyboard.instantiateViewController(withIdentifier: "NotificationPermissionController") as! NotificationPermissionController

        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - FirstActivationControllerDelegate

extension RegistrationCoordinator: FirstActivationControllerDelegate {
    func controllerDidTapContinue(_ controller: FirstActivationController) {
        guard bluetoothAuthorized else {
            showBluetoothScreen()
            return
        }

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

    func controllerDidTapHelp(_ controller: FirstActivationController) {
        showHelpScreen()
    }

    func controllerDidTapAudit(_ controller: FirstActivationController) {
        guard let url = URL(string: RemoteValues.proclamationLink) else { return }
        controller.openURL(URL: url)
    }
}

// MARK: - PhoneNumberControllerDelegate

extension RegistrationCoordinator: PhoneNumberControllerDelegate {
    func controllerDidTapPrivacy(_ controller: PhoneNumberController) {
        guard let url = URL(string: RemoteValues.termsAndConditionsLink) else { return }
        controller.openURL(URL: url)
    }

    func controller(_ controller: PhoneNumberController, didTapContinueWithPhoneNumber phoneNumber: String) {
        controller.showProgress()

        authorizationService.verifyPhoneNumber(phoneNumber) { [weak self, weak controller] result in
            guard let self = self, let controller = controller else { return }

            controller.hideProgress()

            switch result {
            case let .success(verificationId):
                self.showVerificationCodeScreen()
                //self.performSegue(withIdentifier: "verification", sender: AuthData(verificationID: verificationID, phoneNumber: phone))
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

    private func handleError() {

    }

    private func cleanup() {
        try? authorizationService.signOut()

        UserDefaults.resetStandardUserDefaults()
    }
}
