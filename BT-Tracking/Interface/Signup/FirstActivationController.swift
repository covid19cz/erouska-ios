//
//  FirstActivationController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications

final class FirstActivationController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
    }

    // MARK: - Actions
    
    @IBAction private func continueAction() {
        if bluetoothAuthorized {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async { [weak self] in
                    if settings.authorizationStatus == .authorized {
                        // Already authorized
                        self?.performSegue(withIdentifier: "activation", sender: nil)
                    } else {
                        // Request authorization
                        self?.performSegue(withIdentifier: "notification", sender: nil)
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
    
    private var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

}
