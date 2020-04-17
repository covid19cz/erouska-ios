//
//  LoggedInTabBar.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 17/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class LoggedInTabBarController: TabBarController {
    let active = ActiveCoordinator()
    let data = DataCoordinator()
    let contacts = ContactsCoordinator()
    let help = HelpCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [active.navigationController, data.navigationController, contacts.navigationController, help.navigationController]
    }
}
