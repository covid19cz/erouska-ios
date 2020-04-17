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

final class RegistrationCoordinator: Coordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let userNotificationCenter: UNUserNotificationCenter

    private let storyboard = UIStoryboard(name: "Signup", bundle: nil)

    private var bluetoothAuthorized: Bool {
           if #available(iOS 13.0, *) {
               return CBCentralManager().authorization == .allowedAlways
           }
           return CBPeripheralManager.authorizationStatus() == .authorized
       }

    init(
        window: UIWindow,
        navigationController: UINavigationController = UINavigationController(),
        userNotificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    ) {
        self.window = window
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
        let viewController = storyboard.instantiateViewController(withIdentifier: "AccountActivationController") as! AccountActivationController

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
