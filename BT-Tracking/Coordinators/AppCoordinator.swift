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
    private var childCoordinators: [Coordinator] = []

    init(
        window: UIWindow,
        authorizationService: AuthorizationService = DefaultAuthorizationService()
    ) {
        self.authorizationService = authorizationService
        self.window = window
    }

    func start() {
        let coordinator: Coordinator

        if authorizationService.isLoggedIn {
            coordinator = LoggedInCoordinator(window: window)
        } else {
            try? authorizationService.signOut()

            coordinator = RegistrationCoordinator(
                window: window,
                authorizationService: authorizationService
            )
        }

        childCoordinators.append(coordinator)
        coordinator.start()
    }
}
