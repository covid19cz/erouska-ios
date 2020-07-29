//
//  PrivacyVC.swift
// eRouska
//
//  Created by Naim Ashhab on 23/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class PrivacyVC: UIViewController {

    // MARK: -

    private let viewModel = PrivacyVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var continueButton: RoundedButtonFilled!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
        setupStrings()
    }

    // MARK: - Action

    @IBAction func continueAction(_ sender: Any) {
        activateApp()
    }

}

private extension PrivacyVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.help)

        headlineLabel.localizedText(viewModel.headline)
        bodyLabel.localizedText(viewModel.body)
        continueButton.localizedTitle(viewModel.continueButton)
    }

    func activateApp() {
        showProgress()
        Server.shared.requesteHRID { [weak self] result in
            self?.hideProgress()
            switch result {
            case .success(let eHRID):
                AppSettings.eHRID = eHRID
                let storyboard = UIStoryboard(name: "Active", bundle: nil)
                AppDelegate.shared.window?.rootViewController = storyboard.instantiateInitialViewController()
            case .failure(let error):
                self?.show(error: error)
            }
        }
    }

}
