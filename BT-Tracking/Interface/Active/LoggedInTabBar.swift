//
//  LoggedInTabBar.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 17/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class LoggedInTabBarController: TabBarController {
    private let active = ActiveCoordinator()
    private let data = DataCoordinator()
    private let contacts = ContactsCoordinator()
    private let help = HelpCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [
            active.navigationController,
            data.navigationController,
            contacts.navigationController,
            help.navigationController
        ]
    }
}
