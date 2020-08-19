//
//  ExposurePermissionVC.swift
//  eRouska
//
//  Created by Tomas Svoboda on 06/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import UserNotifications

final class ExposurePermissionVC: UIViewController {

    // MARK: -

    private let viewModel = ExposurePermissionVM()

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
        requestExposurePresmission()
    }

}

private extension ExposurePermissionVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.help)
        
        headlineLabel.localizedText(viewModel.headline)
        bodyLabel.localizedText(viewModel.body)
        continueButton.localizedTitle(viewModel.continueButton)
    }

    // MARK: - Request permission

    func requestExposurePresmission() {
        viewModel.exposureService.activate { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                log("ExposurePermissionVC: failed to active exposures \(error)")

                switch error {
                case .activationError(let code):
                    switch code {
                    case .notAuthorized:
                        self.navigationController?.popViewController(animated: true)
                    case .unsupported:
                        self.performSegue(withIdentifier: "unsupported", sender: nil)
                    case .restricted, .notEnabled:
                        self.showAlert(
                            title: self.viewModel.errorRestiredTitle,
                            message: self.viewModel.errorRestiredBody,
                            okHandler: { self.requestNotificationPermission() }
                        )
                    default:
                        self.showUnknownError(error)
                    }
                default:
                    self.showUnknownError(error)
                }
            } else {
                self.requestNotificationPermission()
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

    func showUnknownError(_ error: Error) {
        #if DEBUG
        show(error: error, okHandler: { self.requestNotificationPermission() })
        #else
        showAlert(
            title: viewModel.errorUnknownTitle,
            message: viewModel.errorUnknownBody,
            okHandler: { self.requestNotificationPermission() }
        )
        #endif
    }

}
