//
//  UnregisterFinishVC.swift
//  BT-Tracking
//
//  Created by Bogdan Kurpakov on 31/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class UnregisterFinishVC: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: RoundedButtonFilled!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        titleLabel.text = "Registaci vašeho telefonního čísla jsme zrušili"
        closeButton.setTitle("Zavřit", for: .normal)
    }

    @IBAction func closeButtonDidTap(_ sender: RoundedButtonFilled) {
        let storyboard = UIStoryboard(name: "Signup", bundle: nil)
        AppDelegate.shared.window?.rootViewController = storyboard.instantiateInitialViewController()
    }
}
