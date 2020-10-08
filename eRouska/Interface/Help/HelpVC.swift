//
//  HelpVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HelpVC: MarkdownController {

    @IBOutlet private weak var stackView: UIStackView!

    // MARK: -

    private let viewModel = HelpVM()

    override var markdownContent: String {
        viewModel.markdownContent
    }

    // MARK: -

    override func awakeFromNib() {
        super.awakeFromNib()

        navigationController?.tabBarItem.title = L10n.helpTabTitle
        navigationController?.tabBarItem.image = Asset.help.image
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.helpTitle
        navigationItem.rightBarButtonItem?.title = L10n.about

        stackView.addArrangedSubview(contentView)
    }

}
