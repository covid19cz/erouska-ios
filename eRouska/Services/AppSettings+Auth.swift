//
//  AppSettings+Auth.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 05.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import Foundation
import FirebaseAuth

extension AppSettings {

    /// Cleanup data after logout
    static func deleteAllData() {
        activated = false

        howItWorksClosed = false
        backgroundModeAlertShown = false

        state = nil

        lastProcessedFileNames = [:]
        lastUploadDate = nil

        try? Auth.auth().signOut()
    }

}
