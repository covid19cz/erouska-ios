//
//  NotificationPermissionController.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 06/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

class NotificationPermissionController: UIViewController {
    
    // MARK: - Action
    
    @IBAction func continueAction(_ sender: Any) {
        requestPermission()
    }
    
    // MARK: - Permission request
    
    private func requestPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { [weak self] _, _ in
                self?.performSegue(withIdentifier: "activation", sender: nil)
        })
        UIApplication.shared.registerForRemoteNotifications()
    }
}
