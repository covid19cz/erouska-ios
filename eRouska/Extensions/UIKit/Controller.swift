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

    typealias Callback = () -> Void
    typealias AlertAction = (title: String, handler: Callback?)

    /// show default error alert, localization keys are expected
    func show(error: Error, title: String = L10n.error, okTitle: String = L10n.ok, okHandler: Callback? = nil) {
        showAlert(title: title, message: "\(error)", okTitle: okTitle, okHandler: okHandler)
    }

    /// show alert, localization keys are expected
    func showAlert(title: String = L10n.error, message: String? = nil, okTitle: String = L10n.ok, okHandler: Callback? = nil, action: AlertAction? = nil) {
        let alertController = UIAlertController(
            title: title,
            message: message == nil ? nil : message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(
            title: okTitle,
            style: .cancel,
            handler: { _ in okHandler?() }
        ))
        action.flatMap({ action in
            alertController.addAction(UIAlertAction(
                title: action.title,
                style: .default,
                handler: { _ in action.handler?() }
            ))
        })
        present(alertController, animated: true)
    }

    func openURL(URL: URL) {
        if ["http", "https"].contains(URL.scheme) {
            present(SFSafariViewController(url: URL), animated: true)
        } else {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
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

        guard window.viewWithTag(Self.progressTag) == nil else { return }

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

    func hideProgress(fromView: Bool = false) {
        (fromView ? view : view.window)?.subviews.first { $0.tag == UIViewController.progressTag }?.removeFromSuperview()
    }

}
