//
//  HelpVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import RxSwift
import RxCocoa

final class HelpVC: UIViewController {

    @IBOutlet private weak var textView: UITextView!

    private let bag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupTabBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.isEditable = false
        setupContent()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        textView.textContainerInset = UIEdgeInsets(
            top: 16,
            left: view.layoutMargins.left,
            bottom: 16,
            right: view.layoutMargins.right
        )
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        setupContent()
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

    func setupContent() {
        textView.attributedText = Markdown.attributedString(markdown: RemoteValues.helpMarkdown)
    }
}
