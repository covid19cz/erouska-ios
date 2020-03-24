//
//  ContactsController.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import SafariServices

class ContactsController: UIViewController {

    @IBAction private func importantContactsAction() {
        openURL(URL: URL(string: "https://koronavirus.mzcr.cz/dulezite-kontakty-odkazy/")!)
    }

    @IBAction private func faqAction() {
        openURL(URL: URL(string: "https://koronavirus.mzcr.cz/otazky-odpovedi/")!)
    }

    @IBAction private func call1212Action() {
        guard let url = URL(string: "tel:1212") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction private func webAction() {
        openURL(URL: URL(string: "http://erouska.cz")!)
    }

    private func openURL(URL: URL) {
        let controller = SFSafariViewController(url: URL)
        present(controller, animated: true, completion: nil)
    }

}
