//
//  HelpVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HelpVC: MarkdownController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var chatbotButton: UIButton!

    // MARK: -

    private let viewModel = HelpVM()

    override var markdownContent: String {
        viewModel.markdownContent
    }

    // MARK: -

    override func awakeFromNib() {
        super.awakeFromNib()

        navigationController?.tabBarItem.localizedTitle(viewModel.tabTitle)
        navigationController?.tabBarItem.image = viewModel.tabIcon
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle(viewModel.title)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.about)

        chatbotButton.setTitle(Localizable(viewModel.chatbot), for: .normal)
        chatbotButton.titleLabel?.numberOfLines = 2

        stackView.addArrangedSubview(contentView)
    }

    @IBAction func showChatbot(_ sender: Any) {
        openURL(URL: viewModel.configuration.chatbotURL)
    }

}
