//
//  UnsupportedDeviceVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 20/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class UnsupportedDeviceVC: BaseController {

    // MARK: -

    private let viewModel = UnsupportedDeviceVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var moreInfoButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
    }

    // MARK: - Actions

    @IBAction private func moreInfoAction() {
        guard let url = URL(string: RemoteValues.unsupportedDeviceLink) else { return }
        openURL(URL: url)
    }

    // MARK: -

    private func setupStrings() {
        headlineLabel.text = viewModel.headline
        bodyLabel.text = viewModel.body
        moreInfoButton.setTitle(viewModel.moreInfoButton)
    }
}
