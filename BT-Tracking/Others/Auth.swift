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
        return AppSettings.BUID != nil && Self.auth().currentUser != nil
    }

}
