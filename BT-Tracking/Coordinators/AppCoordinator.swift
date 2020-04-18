//
//  AppCoordinator.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 16/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class AppCoordinator: Coordinator {
    private let authorizationService: AuthorizationService
    private let window: UIWindow
    private let notificationCenter: NotificationCenter

    private var childCoordinators: [Coordinator] = []

    init(
        window: UIWindow,
        authorizationService: AuthorizationService = DefaultAuthorizationService(),
        notificationCenter: NotificationCenter = .default
    ) {
        self.authorizationService = authorizationService
        self.window = window
        self.notificationCenter = notificationCenter

        initNotifications()
    }

    func start() {
        if authorizationService.isLoggedIn {
            startLoggedIn()
        } else {
            try? authorizationService.signOut()
            startRegistration()
        }
    }
}

// MARK: - Start Root Coordinators

private extension AppCoordinator {
    func startLoggedIn() {
        let coordinator = LoggedInCoordinator(window: window)
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    func startRegistration() {
        let coordinator = RegistrationCoordinator(
            window: window,
            authorizationService: authorizationService
        )
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

// MARK: - Notifications

private extension AppCoordinator {
    func initNotifications() {
        notificationCenter.addObserver(
            self,
            selector: #selector(didUnregisterUser),
            name: .didUnregisterUser,
            object: nil
        )
    }

    @objc func didUnregisterUser() {
        childCoordinators.removeAll { $0 is LoggedInCoordinator }

        startRegistration()
    }
}

// MARK: - RegistrationCoordinatorDelegate

extension AppCoordinator: RegistrationCoordinatorDelegate {
    func coordinatorDidFinishRegistration(_ coordinator: RegistrationCoordinator) {
        childCoordinators.removeAll { $0 is RegistrationCoordinator }

        startLoggedIn()
    }
}
