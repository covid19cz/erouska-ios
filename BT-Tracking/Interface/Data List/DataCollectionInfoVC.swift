//
//  DataCollectionInfoVC.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 14/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class DataCollectionInfoVC: UIViewController {

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

    private func initViews() {
        title = "Informace o sběru dat"

        navigationItem.largeTitleDisplayMode = .never

        textView.isEditable = false
        textView.dataDetectorTypes = [.link]
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

    // MARK: - Private

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
        textView.attributedText = Markdown.attributedString(markdown: RemoteValues.dataCollectionMarkdown)
    }
}
