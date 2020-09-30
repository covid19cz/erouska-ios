//
//  FirstActivationController.swift
//  eRouska
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import UserNotifications

final class FirstActivationVC: UIViewController {

    // MARK: -

    private let viewModel = FirstActivationVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var continueButton: Button!
    @IBOutlet private weak var howItWorksButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
        setupStrings()
    }

    // MARK: - Actions

    @IBAction private func continueAction() {
        if viewModel.exposureNotificationAuthorized {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async { [weak self] in
                    if settings.authorizationStatus == .notDetermined {
                        // Request authorization
                        self?.performSegue(withIdentifier: "exposureNotification", sender: nil)
                    } else {
                        // Already authorized or denied
                        self?.performSegue(withIdentifier: "privacy", sender: nil)
                    }
                }
            }
        } else {
            performSegue(withIdentifier: "exposureNotification", sender: nil)
        }
    }

}

private extension FirstActivationVC {
    func setupStrings() {
        navigationItem.localizedTitle(.app_name)
        navigationItem.backBarButtonItem?.localizedTitle(.back)

        headlineLabel.localizedText(.welcome_title)
        bodyLabel.localizedText(.welcome_body)
        continueButton.localizedTitle(.welcome_activation)
        howItWorksButton.localizedTitle(.welcome_help)
    }
}
