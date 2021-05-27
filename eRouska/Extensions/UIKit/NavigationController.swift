//
//  NavigationController.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 25/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class NavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        } else {
            return .portrait
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarToWhite()
    }

    private func setNavigationBarToWhite() {
        if #available(iOS 13, *) {
            return
        }
        view.backgroundColor = .white

        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }

}
