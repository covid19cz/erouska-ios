//
//  HelpVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import RxSwift
import RxCocoa
import MarkdownKit

class HelpVC: UIViewController {

    @IBOutlet private weak var textView: UITextView!

    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        setupTextView()
        showContent()
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

    func setupTextView() {
        textView.textContainerInset = UIEdgeInsets(top: 30, left: 16, bottom: 16, right: 16)
    }

    func showContent() {
        let markdownParser = MarkdownParser()
        let helpMarkdown = RemoteValues.helpMarkdown.replacingOccurrences(of: "\\n", with: "\u{0085}")
        textView.attributedText = markdownParser.parse(helpMarkdown)
    }
}
