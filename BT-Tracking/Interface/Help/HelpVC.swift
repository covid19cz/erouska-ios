//
//  HelpVC.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 17/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HelpVC: MarkdownController {

    override var markdownContent: String {
        RemoteValues.helpMarkdown
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Jak to funguje"

        // TODO: msrutek, add right bar button item - about app
    }

}
