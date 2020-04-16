//
//  ActiveCoordinator.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 17/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ActiveCoordinator: Coordinator {

    let navigationController: UINavigationController
    private let storyboard = UIStoryboard(name: "Active", bundle: nil)

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true

        let viewController = storyboard.instantiateViewController(withIdentifier: "ActiveAppController") as! ActiveAppController
        navigationController.viewControllers = [viewController]

        if #available(iOS 13, *) {
            viewController.tabBarItem = UITabBarItem(title: "eRouška", image: UIImage(systemName: "phone"), tag: 0)
        } else {
            viewController.tabBarItem = UITabBarItem(title: "eRouška", image: UIImage(named: "phone")?.resize(toWidth: 26), tag: 0)
        }
    }

    func start() {}
}
