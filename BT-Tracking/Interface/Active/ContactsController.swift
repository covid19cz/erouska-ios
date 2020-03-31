//
//  ContactsController.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import SafariServices
import UIKit

final class ContactsController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *) {
            navigationController?.tabBarItem.image = UIImage(systemName: "phone")
        } else {
            navigationController?.tabBarItem.image = UIImage(named: "phone")?.resize(toWidth: 26)
        }
    }

    @IBAction private func importantContactsAction() {
        openURL(URL: URL(string: "https://koronavirus.mzcr.cz/dulezite-kontakty-odkazy/")!)
    }

    @IBAction private func faqAction() {
        if let url = URL(string: RemoteValues.faqLink) {
            openURL(URL: url)
        }
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
