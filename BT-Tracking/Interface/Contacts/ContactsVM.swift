//
//  ContactsVM.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct ContactsVM {

    let tabTitle = "contacts_title"
    var tabIcon: UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "phone")
        } else {
            return UIImage(named: "phone")?.resize(toWidth: 26)
        }
    }

    let title = "contacts_title"

    let importantHeadline = "contacts_important_headline"
    let importantBody = "contacts_important_body"
    let importantButton = "contacts_important_button"

    let helpHeadline = "contacts_help_headline"
    let helpBody = "contacts_help_body"
    let helpFaqButton = "contacts_help_faq_button"

    let aboutHeadline = "contacts_about_headline"
    let aboutBody = "contacts_about_body"
    let aboutButton = "contacts_about_button"

}
