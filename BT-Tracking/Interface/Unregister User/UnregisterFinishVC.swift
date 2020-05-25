//
//  UnregisterFinishVC.swift
//  BT-Tracking
//
//  Created by Bogdan Kurpakov on 31/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class UnregisterFinishVC: UIViewController {

    // MARK: -

    private let viewModel = UnregisterFinishVM()

    // MARK: - Outlets

    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var closeButton: RoundedButtonFilled!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        navigationItem.localizedTitle(viewModel.title)

        headlineLabel.localizedText(viewModel.headline)
        closeButton.localizedTitle(viewModel.closeButton)
    }

    // MARK: - Actions

    @IBAction private func closeButtonDidTap(_ sender: RoundedButtonFilled) {
        let storyboard = UIStoryboard(name: "Signup", bundle: nil)
        AppDelegate.shared.window?.rootViewController = storyboard.instantiateInitialViewController()
    }

}
