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

    @IBOutlet weak var textView: UITextView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle(viewModel.titleKey)

        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        textView.hyperLink(
            originalText: Localizable(viewModel.infoKey),
            hyperLink: Localizable(viewModel.infoLink),
            urlString: viewModel.conditionsOfUseLink
        )
    }
}
