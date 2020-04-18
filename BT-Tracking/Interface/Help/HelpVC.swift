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

        navigationItem.title = "Jak to funguje"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "O aplikaci", style: .plain, target: self, action: #selector(didTapAbout))
    }

    // MARK: - Actions

    @objc private func didTapAbout() {
        guard let url = URL(string: RemoteValues.aboutLink) else { return }
        openURL(URL: url)
    }

}
