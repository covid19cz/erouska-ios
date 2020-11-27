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
            imageView.image = viewModel.imageAsset.image
            headlineLabel.text = viewModel.headline
            if let bodyLink = viewModel.bodyLink, let bodyLinkTitle = viewModel.bodyLinkTitle {
                bodyTextView.hyperLink(originalText: viewModel.body, hyperLink: bodyLinkTitle, urlString: bodyLink)
            } else {
                bodyTextView.text = viewModel.body
            }

            if let switchTitle = viewModel.switchTitle {
                switchLabel.text = switchTitle
                switchLabel.superview?.isHidden = false
                headlineLabel.textAlignment = .left
                bodyTextView.textAlignment = .left
            } else {
                switchLabel.superview?.isHidden = true
                headlineLabel.textAlignment = .center
                bodyTextView.textAlignment = .center
            }
        }
    }

    // MARK: - Outlets

    weak var bodyTextDelegate: UITextViewDelegate? {
        set {
            bodyTextView.delegate = newValue
        }
        get {
            bodyTextView.delegate
        }
    }

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyTextView: UITextView! {
        didSet {
            bodyTextView.textContainerInset = .zero
            bodyTextView.textContainer.lineFragmentPadding = 0
        }
    }
    @IBOutlet private weak var switchLabel: UILabel!
    @IBOutlet private weak var switchView: UISwitch!

    // MARK: -

    override func awakeFromNib() {
        super.awakeFromNib()

        switchValueChange()
    }

    @IBAction private func switchValueChange() {
        viewModel?.switchCallback?(switchView.isOn)
    }

}
