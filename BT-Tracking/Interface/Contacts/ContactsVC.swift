//
//  ContactsVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ContactsVC: UIViewController {

    // MARK: -

    private let viewModel = ContactsVM()

    // MARK: - Outlets

    @IBOutlet weak var importantHeadlineLabel: UILabel!
    @IBOutlet weak var importantBodyLabel: UILabel!
    @IBOutlet weak var importantButton: UIButton!

    @IBOutlet weak var helpHeadlineLabel: UILabel!
    @IBOutlet weak var helpBodyLabel: UILabel!
    @IBOutlet weak var helpFaqButton: UIButton!

    @IBOutlet weak var aboutHeadlineLabel: UILabel!
    @IBOutlet weak var aboutBodyLabel: UILabel!
    @IBOutlet weak var aboutButton: UIButton!

    // MARK: -

    override func awakeFromNib() {
        super.awakeFromNib()

        setupTabBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
    }

    // MARK: - Actions

    @IBAction private func importantContactsAction() {
        if let url = URL(string: RemoteValues.importantLink) {
            openURL(URL: url)
        }
    }

    @IBAction private func faqAction() {
        if let url = URL(string: RemoteValues.faqLink) {
            openURL(URL: url)
        }
    }

    @IBAction private func webAction() {
        guard let url = URL(string: RemoteValues.homepageLink) else { return }
        openURL(URL: url)
    }

}

private extension ContactsVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)

        importantHeadlineLabel.localizedText(viewModel.importantHeadline)
        importantBodyLabel.localizedText(viewModel.importantBody)
        importantButton.localizedTitle(viewModel.importantButton)

        helpHeadlineLabel.localizedText(viewModel.helpHeadline)
        helpBodyLabel.localizedText(viewModel.helpBody)
        helpFaqButton.localizedTitle(viewModel.helpFaqButton)

        aboutHeadlineLabel.localizedText(viewModel.aboutHeadline)
        aboutBodyLabel.localizedText(viewModel.aboutBody)
        aboutButton.localizedTitle(viewModel.aboutButton)
    }

    func setupTabBar() {
        navigationController?.tabBarItem.localizedTitle(viewModel.tabTitle)
        navigationController?.tabBarItem.image = viewModel.tabIcon
    }

}
