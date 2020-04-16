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

    func showError(title: String = "Chyba", message: String, okTitle: String? = "OK", okHandler: (() -> Void)? = nil, action: (title: String, handler: (() -> Void)?)? = nil) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: okTitle, style: .cancel, handler: { _ in okHandler?() }))
        action.flatMap({ action in alertController.addAction(UIAlertAction(title: action.title, style: .default, handler: { _ in action.handler?() })) })
        present(alertController, animated: true)
    }

    func openURL(URL: URL) {
        present(SFSafariViewController(url: URL), animated: true)
    }

    private static let progressTag = 42

    /// shows overlay over current UIViewController's window, if it has one
    func showProgress() {
        guard let window = view.window else { return }

        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.tag = UIViewController.progressTag

        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        overlay.addSubview(activityIndicator)

        window.addSubview(overlay)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),

            overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: window.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: window.bottomAnchor),
        ])
    }

    func hideProgress() {
        view.window?.subviews.first { $0.tag == UIViewController.progressTag }?.removeFromSuperview()
    }

}
