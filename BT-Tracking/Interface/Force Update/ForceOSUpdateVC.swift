//
//  ForceOSUpdateVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 17/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ForceOSUpdateVC: UIViewController {

    // MARK: -

    private let viewModel = ForceOSUpdateVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var updateButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
    }

    // MARK: - Actions

    @IBAction private func updateAction() {
        UIApplication.shared.open(viewModel.settingsURL)
    }

    // MARK: -

    private func setupStrings() {
        headlineLabel.localizedText(viewModel.headline)
        bodyLabel.localizedText(viewModel.body)
        updateButton.localizedTitle(viewModel.updateButton)
    }
}
