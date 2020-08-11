//
//  HelpVM.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct HelpVM {

    let title = "help_title"

    let tabTitle = "help_tab_title"
    let tabIcon = UIImage(systemName: "questionmark.circle")

    let about = "about"

    var markdownContent: String {
        return RemoteValues.helpMarkdown
    }

}
