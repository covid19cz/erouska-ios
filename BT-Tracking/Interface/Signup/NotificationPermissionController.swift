//
//  NotificationPermissionController.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 06/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import UserNotifications

protocol NotificationPermissionControllerDelegate: AnyObject {
    func controllerDidTapContinue(_ controller: NotificationPermissionController)
}

final class NotificationPermissionController: UIViewController {

    weak var delegate: NotificationPermissionControllerDelegate?

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
    }

    // MARK: - Action
    
    @IBAction func didTapContinue(_ sender: Any) {
        delegate?.controllerDidTapContinue(self)
    }
}
