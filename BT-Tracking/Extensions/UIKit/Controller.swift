//
//  Controller.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {

    func show(error: Error, title: String = "Chyba") {
        showError(title: title, message: error.localizedDescription)
    }

    func showError(
        pageTitle: String? = nil,
        title: String = "Chyba",
        message: String,
        primaryAction: (title: String, handler: (() -> Void)?)? = nil,
        secondaryAction: (title: String, handler: (() -> Void)?)? = nil
    ) {
        let errorController = ErrorController(
            pageTitle: pageTitle,
            title: title,
            message: message,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction
        )
        if #available(iOS 13.0, *) {
            errorController.isModalInPresentation = true
        }

        present(UINavigationController(rootViewController: errorController), animated: true)
    }

     func showAlert(
        title: String = "Chyba",
        message: String,
        okTitle: String? = "OK",
        okHandler: (() -> Void)? = nil,
        action: (title: String, handler: (() -> Void)?)? = nil
     ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okTitle, style: .cancel, handler: { _ in okHandler?() }))
        action.flatMap({ action in alertController.addAction(UIAlertAction(title: action.title, style: .default, handler: { _ in action.handler?() })) })
        present(alertController, animated: true)
    }

    func openURL(URL: URL) {
        let controller = SFSafariViewController(url: URL)
        present(controller, animated: true, completion: nil)
    }

}
