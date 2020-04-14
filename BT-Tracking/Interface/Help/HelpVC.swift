//
//  HelpVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import MarkdownKit
import RxCocoa
import RxSwift

final class HelpVC: UIViewController {
    @IBOutlet private var textView: UITextView!

    private let bag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupTabBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showContent()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        textView.textContainerInset = UIEdgeInsets(
            top: 16,
            left: view.layoutMargins.left,
            bottom: 16,
            right: view.layoutMargins.right)
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

    func showContent() {
        let markdownParser = MarkdownParser(font: UIFont.preferredFont(forTextStyle: .body))
        markdownParser.list.indicator = "•"
        var helpMarkdown = RemoteValues.helpMarkdown.replacingOccurrences(of: "\\n", with: "\u{0085}")
        helpMarkdown = helpMarkdown.replacingOccurrences(of: "([Android](https://github.com/covid19cz/erouska-android), [iOS](https://github.com/covid19cz/erouska-ios))", with: "pro [Android](https://github.com/covid19cz/erouska-android) a [iOS](https://github.com/covid19cz/erouska-ios)")
        helpMarkdown = helpMarkdown.replacingOccurrences(of: "[iOS](https://github.com/covid19cz/erouska-ios))", with: "[iOS](https://github.com/covid19cz/erouska-ios) )")

        let attributedText = NSMutableAttributedString(attributedString: markdownParser.parse(helpMarkdown))
        var textColor: UIColor {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        }
        attributedText.addAttribute(.foregroundColor, value: textColor, range: NSMakeRange(0, attributedText.length))

        textView.attributedText = attributedText
    }
}
