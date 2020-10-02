//
//  AboutVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 21/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class AboutVC: UIViewController {

    private let viewModel = AboutVM()

    // MARK: - Outlets

    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var versionLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.aboutTitle

        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        textView.hyperLink(
            originalText: L10n.aboutInfo,
            hyperLink: L10n.aboutInfoLink,
            urlString: viewModel.conditionsOfUseLink
        )

        versionLabel.text = L10n.version + " " + App.appVersion.rawValue + " (\(App.bundleBuild))"
    }
}
