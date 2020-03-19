//
//  Controller.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

extension UIViewController {

    func show(error: Error, title: String = "Chyba") {
        showError(title: title, message: error.localizedDescription)
    }

    func showError(title: String = "Chyba", message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}
