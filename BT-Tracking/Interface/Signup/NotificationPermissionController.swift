//
//  NotificationPermissionController.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 06/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import UserNotifications

final class NotificationPermissionController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
    }

    // MARK: - Action
    
    @IBAction func continueAction(_ sender: Any) {
        requestPermission()
    }
    
    // MARK: - Request permission
    
    private func requestPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { [weak self] _, _ in
                DispatchQueue.main.async { [weak self] in
                    self?.performSegue(withIdentifier: "activation", sender: nil)
                }
        })
        UIApplication.shared.registerForRemoteNotifications()
    }
}
