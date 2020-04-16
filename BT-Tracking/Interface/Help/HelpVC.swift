//
//  HelpVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HelpVC: MarkdownController {

    override var markdownContent: String {
        RemoteValues.helpMarkdown
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupTabBar()
    }

    // MARK: - Actions

    @IBAction private func aboutAction() {
        guard let url = URL(string: RemoteValues.aboutLink) else { return }
        openURL(URL: url)
    }
}

private extension HelpVC {

    func setupTabBar() {
        if #available(iOS 13, *) {
            navigationController?.tabBarItem.image = UIImage(systemName: "questionmark.circle")
        } else {
            navigationController?.tabBarItem.image = UIImage(named: "questionmark.circle")?.resize(toWidth: 26)
        }
    }

}
