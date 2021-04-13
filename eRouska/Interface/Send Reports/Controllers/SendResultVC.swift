//
//  SendResultVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import DeviceKit
import StoreKit

final class SendResultVC: BaseController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasDiagnosis

    var dependencies: Dependencies!

    // MARK: -

    var viewModel: SendResultVM = .standard

    private var diagnosis: Diagnosis?

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var closeButton: Button!
    @IBOutlet private weak var actionButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))
        if Device.current.diagonal < 4.1 {
            navigationItem.largeTitleDisplayMode = .never
        }

        imageView.image = viewModel.image
        titleLabel.text = viewModel.titleLabel
        titleLabel.textColor = viewModel.titleLabelColor
        headlineLabel.text = viewModel.headline
        bodyLabel.text = viewModel.body
        closeButton.setTitle(viewModel.buttonTitle)

        if let title = viewModel.actionTitle {
            actionButton.setTitle(title)
        } else {
            actionButton.isHidden = true
        }

        let closeSelector: Selector
        if case .codeInvalid = viewModel {
            closeSelector = #selector(backAction)
        } else if case .error = viewModel {
            closeSelector = #selector(mailAction)
        } else {
            closeSelector = #selector(closeAction)
        }
        closeButton.addTarget(self, action: closeSelector, for: .touchUpInside)

        buttonsView.connect(with: scrollView)

        isModalInPresentation = true
    }

    // MARK: - Action

    @IBAction private func backAction() {
        navigationController?.popViewController(animated: true)
    }

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
        if dependencies.diagnosis.canSendMail {
            if case let .error(code, message) = viewModel {
                dependencies.diagnosis.present(fromController: self, screenName: .sendCodeResult, kind: .error(.init(code: code, message: message ?? "None")))
            } else if viewModel == .codeInvalid {
                dependencies.diagnosis.present(fromController: self, screenName: .sendWrongCode, kind: .wrongCode)
            } else {
                dependencies.diagnosis.present(fromController: self, screenName: .sendCodeResult, kind: .error(nil))
            }
        } else if let URL = URL(string: "mailto:info@erouska.cz") {
            openURL(URL: URL)
        }
    }

}
