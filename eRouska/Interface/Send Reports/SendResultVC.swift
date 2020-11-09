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

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var closeButton: Button!

    var viewModel: SendResultVM = .standard

    private var diagnosis: Diagnosis?

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))

        imageView.image = viewModel.image
        titleLabel.text = viewModel.titleLabel
        titleLabel.textColor = viewModel.titleLabelColor
        headlineLabel.text = viewModel.headline
        bodyLabel.text = viewModel.body
        closeButton.setTitle(viewModel.buttonTitle)

        if case .error = viewModel {
            closeButton.addTarget(self, action: #selector(mailAction), for: .touchUpInside)
        } else {
            closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        }
    }

    // MARK: - Action

    @IBAction private func closeAction() {
        dismiss(animated: true, completion: { [weak self] in
            switch self?.viewModel {
            case .standard:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    SKStoreReviewController.requestReview()
                }
            default:
                break
            }
        })
    }

    @IBAction private func mailAction() {
        if Diagnosis.canSendMail {
            diagnosis = Diagnosis(showFromController: self)
        } else if let URL = URL(string: "mailto:info@erouska.cz") {
            openURL(URL: URL)
        }
    }

}
