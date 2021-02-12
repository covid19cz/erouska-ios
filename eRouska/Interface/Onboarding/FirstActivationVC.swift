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
                        self?.perform(segue: StoryboardSegue.Onboarding.exposureNotification)
                    } else {
                        // Already authorized or denied
                        self?.perform(segue: StoryboardSegue.Onboarding.privacy)
                    }
                }
            }
        } else {
            perform(segue: StoryboardSegue.Onboarding.exposureNotification)
        }
    }

}

private extension FirstActivationVC {
    func setupStrings() {
        title = L10n.appName
        navigationItem.backBarButtonItem?.title = L10n.back

        headlineLabel.text = L10n.welcomeTitle
        bodyLabel.text = L10n.welcomeBody
        continueButton.setTitle(L10n.welcomeActivation)
        howItWorksButton.setTitle(L10n.welcomeHelp)
    }
}
