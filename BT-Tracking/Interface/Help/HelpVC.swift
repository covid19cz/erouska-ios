//
//  HelpVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HelpVC: MarkdownController {

    // MARK: -

    private let viewModel = HelpVM()

    override var markdownContent: String {
        viewModel.markdownContent
    }

    // MARK: -

    override func awakeFromNib() {
        super.awakeFromNib()

        setupTabBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle(viewModel.title)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.about)
    }

}

private extension HelpVC {

    func setupTabBar() {
        navigationController?.tabBarItem.localizedTitle(viewModel.tabTitle)
        navigationController?.tabBarItem.image = viewModel.tabIcon
    }

}
