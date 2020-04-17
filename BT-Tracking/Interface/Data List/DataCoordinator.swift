//
//  DataCoordinator.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 17/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class DataCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let storyboard = UIStoryboard(name: "DataList", bundle: nil)

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController

        navigationController.navigationBar.prefersLargeTitles = true

        let viewController = storyboard.instantiateViewController(withIdentifier: "DataListVC") as! DataListVC
        navigationController.viewControllers = [viewController]

        if #available(iOS 13, *) {
            viewController.tabBarItem = UITabBarItem(title: "Moje Data", image: UIImage(systemName: "doc.plaintext"), tag: 0)
        } else {
            viewController.tabBarItem = UITabBarItem(title: "Moje Data", image: UIImage(named: "doc.plaintext")?.resize(toWidth: 20), tag: 0)
        }
    }

    func start() {}
}
