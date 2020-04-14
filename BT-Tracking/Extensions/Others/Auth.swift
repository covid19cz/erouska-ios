//
//  Auth.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 02/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import FirebaseAuth

extension Auth {
    static var isLoggedIn: Bool {
        KeychainService.BUID != nil && KeychainService.TUIDs != nil && Self.auth().currentUser != nil
    }
}

extension String {
    var phoneFormatted: String {
        let countryCode = dropLast(9)
        let phone = String(suffix(9))
        return countryCode + " " + phone.chunkFormatted(withChunkSize: 3)
    }
}
