//
//  Controller.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 19/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {

    /// show default error alert, localization keys are expected
    func show(error: Error, title: String = "error", okTitle: String = "ok", okHandler: (() -> Void)? = nil) {
        showAlert(title: title, message: "\(error)", okTitle: okTitle, okHandler: okHandler)
    }

    /// show alert, localization keys are expected
    func showAlert(title: String = "error", message: String? = nil, okTitle: String = "ok", okHandler: (() -> Void)? = nil, action: (title: String, handler: (() -> Void)?)? = nil) {
        let alertController = UIAlertController(
            title: Localizable(title),
            message: message == nil ? nil : Localizable(message ?? ""),
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(
            title: Localizable(okTitle),
            style: .cancel,
            handler: { _ in okHandler?() }
        ))
        action.flatMap({ action in
            alertController.addAction(UIAlertAction(
                title: Localizable(action.title),
                style: .default,
                handler: { _ in action.handler?() }
            ))
        })
        present(alertController, animated: true)
    }

    func openURL(URL: URL) {
        present(SFSafariViewController(url: URL), animated: true)
    }

    private static let progressTag = 42

    /// shows overlay over current UIViewController's window, if it has one
    func showProgress(fromView: Bool = false) {
        let window: UIView

        if fromView {
            window = view
        } else if let view = view.window {
            window = view
        } else {
            return
        }
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.tag = UIViewController.progressTag

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        overlay.addSubview(activityIndicator)

        window.addSubview(overlay)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),

            overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: fromView ? window.safeAreaLayoutGuide.topAnchor : window.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: fromView ? window.safeAreaLayoutGuide.bottomAnchor : window.bottomAnchor),
        ])
    }

    func hideProgress() {
        view.window?.subviews.first { $0.tag == UIViewController.progressTag }?.removeFromSuperview()
    }

}
