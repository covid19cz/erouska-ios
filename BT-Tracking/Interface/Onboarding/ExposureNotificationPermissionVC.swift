//
//  ExposureNotificationPermissionVC.swift
// eRouska
//
//  Created by Tomas Svoboda on 06/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import UserNotifications

final class ExposureNotificationPermissionVC: UIViewController {

    // MARK: -

    private let viewModel = ExposureNotificationPermissionVM()

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
        requestExposureNotificationPresmission()
    }

}

private extension ExposureNotificationPermissionVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.help)
        
        headlineLabel.localizedText(viewModel.headline)
        bodyLabel.localizedText(viewModel.body)
        continueButton.localizedTitle(viewModel.continueButton)
    }

    // MARK: - Request permission

    func requestExposureNotificationPresmission() {
        viewModel.exposureService.activate { [weak self] error in
            if let error = error {
                self?.show(error: error, okHandler: { self?.requestNotificationPermission() })
            } else {
                self?.requestNotificationPermission()
            }
        }
    }

    func requestNotificationPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { [weak self] _, _ in
                DispatchQueue.main.async { [weak self] in
                    self?.performSegue(withIdentifier: "privacy", sender: nil)
                }
        })
        UIApplication.shared.registerForRemoteNotifications()
    }

}
