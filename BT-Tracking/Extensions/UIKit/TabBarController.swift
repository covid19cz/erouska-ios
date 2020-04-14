//
//  TabBarController.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        for controller in viewControllers ?? [] {
            _ = controller.view
            if let navController = controller as? UINavigationController {
                _ = navController.topViewController?.view
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        } else {
            return .portrait
        }
    }

}
