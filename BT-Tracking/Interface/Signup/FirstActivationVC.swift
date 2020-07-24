//
//  FirstActivationController.swift
// eRouska
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import UserNotifications

final class FirstActivationVC: UIViewController {

    // NARK: -

    private let viewModel = FirstActivationVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var moreButton: UIButton!
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
        if viewModel.bluetoothAuthorized {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async { [weak self] in
                    if settings.authorizationStatus == .notDetermined {
                        // Request authorization
                        self?.performSegue(withIdentifier: "notification", sender: nil)
                    } else {
                        // Already authorized or denied
                        self?.performSegue(withIdentifier: "activation", sender: nil)
                    }
                }
            }
        } else {
            performSegue(withIdentifier: "bluetooth", sender: nil)
        }
    }
    
    @IBAction private func auditsURLAction(_ sender: Any) {
        guard let url = URL(string: RemoteValues.proclamationLink) else { return }
        openURL(URL: url)
    }

}

private extension FirstActivationVC {
    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)

        headlineLabel.localizedText(viewModel.headline)
        bodyLabel.localizedText(viewModel.body)
        moreButton.localizedTitle(viewModel.moreButton)
        continueButton.localizedTitle(viewModel.continueButton)
        howItWorksButton.localizedTitle(viewModel.howItWorksButton)
    }
}
