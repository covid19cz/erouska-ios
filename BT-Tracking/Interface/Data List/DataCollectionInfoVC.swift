//
//  DataCollectionInfoVC.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 14/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import MarkdownKit

final class DataCollectionInfoVC: UIViewController {

    // MARK: Private Properties
    private let textView = UITextView()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        layoutViews()
        setupContent()
    }

    // MARK: Setup

    private func initViews() {
        title = "Informace o sběru dat"

        navigationItem.largeTitleDisplayMode = .never

        textView.isEditable = false
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        textView.textContainerInset = UIEdgeInsets(
            top: 30,
            left: view.layoutMargins.left,
            bottom: 16,
            right: view.layoutMargins.right
        )
    }

    private func layoutViews() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupContent() {
        let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 16))
        let markdownText = RemoteValues.dataCollectionMarkdown.replacingOccurrences(of: "\\n", with: "\u{0085}")

        let attributedText = NSMutableAttributedString(attributedString: markdownParser.parse(markdownText))
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
