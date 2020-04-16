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

protocol FirstActivationControllerDelegate: AnyObject {
    func controllerDidTapContinue(_ controller: FirstActivationController)
    func controllerDidTapAudit(_ controller: FirstActivationController)
}

final class FirstActivationController: UIViewController {

    // MARK: - Public Properties

    weak var delegate: FirstActivationControllerDelegate?

    // MARK: - Private Properties

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
    }

    // MARK: - Actions
    
    @IBAction private func didTapContinue() {
        delegate?.controllerDidTapContinue(self)

        if true {
            return
        }

        if bluetoothAuthorized {
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
    
    @IBAction private func didTapAudit(_ sender: Any) {
        delegate?.controllerDidTapAudit(self)
    }
    
    private var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

}
