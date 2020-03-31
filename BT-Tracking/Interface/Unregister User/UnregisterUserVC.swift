//
//  UnregisterUserVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 30/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth

final class UnregisterUserVC: UIViewController {

    @IBOutlet private weak var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        textLabel.text = textLabel.text?.replacingOccurrences(of: "%@", with: Auth.auth().currentUser?.phoneNumber ?? "")

    }

    // MARK: - Actions

    @IBAction private func unregisterAction() {
        showError(message: "TODO")
    }

}
