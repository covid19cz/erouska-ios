//
//  NewsPageView.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 28/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class NewsPageView: UIView {

    // MARK: -

    var viewModel: NewsPageVM? {
        didSet {
            guard let viewModel = viewModel else { return }
            imageView.image = UIImage(named: viewModel.imageName)
            headlineLabel.localizedText(viewModel.headline)
            if let bodyLink = viewModel.bodyLink, let bodyLinkTitle = viewModel.bodyLinkTitle {
                bodyTextView.hyperLink(originalText: Localizable(viewModel.body), hyperLink: Localizable(bodyLinkTitle), urlString: bodyLink)
            } else {
                bodyTextView.text = Localizable(viewModel.body)
            }
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView! {
        didSet {
            bodyTextView.textContainerInset = .zero
            bodyTextView.textContainer.lineFragmentPadding = 0
        }
    }
}
