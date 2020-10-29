//
//  SendResultVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import StoreKit

final class SendResultVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var closeButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.dataSendTitle
        navigationItem.hidesBackButton = true

        titleLabel.text = L10n.dataSendTitleLabel
        headlineLabel.text = L10n.dataSendHeadline
        bodyLabel.text = L10n.dataSendBody
        closeButton.setTitle(L10n.dataSendCloseButton)
    }

    // MARK: - Action

    @IBAction private func closeAction() {
        dismiss(animated: true, completion: nil)

        SKStoreReviewController.requestReview()
    }

}
