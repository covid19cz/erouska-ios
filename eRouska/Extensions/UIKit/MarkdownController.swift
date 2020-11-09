//
//  MarkdownController.swift
//  eRouska
//
//  Created by Michal Šrůtek on 14/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import SwiftyMarkdown

class MarkdownController: UIViewController {

    // MARK: - Public Properties

    var markdownContent: String = ""
    var markdownLines: [SwiftyLine] = []
    var contentView = UIView()

    // MARK: - Private Properties

    private let textView = UITextView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        layoutViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupContent()
    }

    // MARK: - Setup

    private func setupContent() {
        textView.attributedText = Markdown.attributedString(markdown: markdownContent, lines: markdownLines)
    }

    private func initViews() {
        textView.text = ""
        textView.isEditable = false
        textView.dataDetectorTypes = [.link]
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        textView.textContainerInset = UIEdgeInsets(
            top: 16,
            left: 11,
            bottom: 16,
            right: 11
        )
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        setupContent()
    }

    // MARK: - Private

    private func layoutViews() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        contentView.setContentHuggingPriority(UILayoutPriority(249), for: .vertical)
    }

}
