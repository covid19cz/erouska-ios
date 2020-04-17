//
//  HelpCoordinator.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 17/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HelpCoordinator: Coordinator {

    let navigationController: UINavigationController

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController

        navigationController.navigationBar.prefersLargeTitles = true

        let viewController = HelpVC()
        navigationController.viewControllers = [viewController]

        if #available(iOS 13, *) {
            viewController.tabBarItem = UITabBarItem(title: "Nápověda", image: UIImage(systemName: "questionmark.circle"), tag: 0)
        } else {
            viewController.tabBarItem = UITabBarItem(title: "Nápověda", image: UIImage(named: "questionmark.circle")?.resize(toWidth: 26), tag: 0)
        }
    }

    func start() {}
}
