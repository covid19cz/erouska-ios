//
//  HelpVM.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct HelpVM {

    let title = "help_title"

    let tabTitle = "help_tab_title"
    var tabIcon: UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "questionmark.circle")
        } else {
            return UIImage(named: "questionmark.circle")?.resize(toWidth: 26)
        }
    }

    let about = "about"

    var markdownContent: String {
        return RemoteValues.helpMarkdown
    }

}
