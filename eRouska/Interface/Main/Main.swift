//
//  Main.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 10.12.2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

enum MainTab: Int {

    case active = 1
    case news = 2
    case contacts = 3
    case help = 4

}

extension AppDelegate: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch MainTab(rawValue: tabBarController.tabBar.selectedItem?.tag ?? 0) {
        case .active:
            Events.tapTabHome.logEvent()
        case .news:
            Events.tapTabNews.logEvent()
        case .contacts:
            Events.tapTabContacts.logEvent()
        case .help:
            Events.tapTabHelp.logEvent()
        default:
            break
        }
    }

}
