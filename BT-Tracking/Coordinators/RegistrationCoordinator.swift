//
//  RegistrationCoordinator.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 16/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class RegistrationCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let window: UIWindow

    private let storyboard = UIStoryboard(name: "Signup", bundle: nil)

    init(
        window: UIWindow,
        navigationController: UINavigationController = UINavigationController()
    ) {
        self.navigationController = navigationController
        self.window = window

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
}

// MARK: - FirstActivationControllerDelegate

extension RegistrationCoordinator: FirstActivationControllerDelegate {
    func controllerDidTapContinue(_ controller: FirstActivationController) {

    }

    func controllerDidTapAudit(_ controller: FirstActivationController) {
        guard let url = URL(string: RemoteValues.proclamationLink) else { return }
        controller.openURL(URL: url)
    }
}
