//
//  NotificationPermissionController.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 06/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

class NotificationPermissionController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action
    
    @IBAction func continueAction(_ sender: Any) {
        performSegue(withIdentifier: "activation", sender: nil)
    }
}
