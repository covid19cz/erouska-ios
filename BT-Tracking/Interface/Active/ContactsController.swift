//
//  ContactsController.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

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
        if let url = URL(string: RemoteValues.importantLink) {
            openURL(URL: url)
        }
    }

    @IBAction private func faqAction() {
        if let url = URL(string: RemoteValues.faqLink) {
            openURL(URL: url)
        }
    }

    @IBAction private func call1212Action() {
        guard let url = URL(string: "tel:\(RemoteValues.emergencyPhonenumber)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    @IBAction private func webAction() {
        guard let url = URL(string: RemoteValues.homepageLink) else { return }
        openURL(URL: url)
    }

}
