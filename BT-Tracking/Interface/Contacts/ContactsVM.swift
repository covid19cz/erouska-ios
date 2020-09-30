//
//  ContactsVM.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct ContactsVM {

    let tabTitle = "contacts_title"
    let tabIcon = Asset.contacts.image

    let title = "contacts_title"

    var contacts: [Contact] {
        RemoteValues.contactsContent
    }

}

struct Contact {
    let title: String
    let text: String
    let linkTitle: String
    let link: URL
}

struct ContactContent: Decodable {
    let title: String
    let text: String
    let linkTitle: String
    let link: String
}
