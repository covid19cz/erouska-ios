//
//  LoggedInCoordinator.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 16/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class LoggedInCoordinator: Coordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        setupWindow()
    }

    private func setupWindow() {
        window.rootViewController = LoggedInTabBarController()
        window.makeKeyAndVisible()
    }
}
