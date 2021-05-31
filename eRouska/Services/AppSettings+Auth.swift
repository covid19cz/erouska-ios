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

    /// Last processed file name [country code: file name]
    static var lastProcessedFileNames: ReportServicing.ProcessedFileNames {
        get {
            dictionary(forKey: .lastProcessedFileNames).compactMapValues { $0 as? String }
        }
        set {
            set(withKey: .lastProcessedFileNames, value: newValue)
        }
    }

    static var sendReport: SendReport? {
        get {
            guard let data = data(forKey: .sendReport) else { return nil }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try? decoder.decode(SendReport.self, from: data)
        }
        set {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            set(withKey: .sendReport, value: try? encoder.encode(newValue))
        }
    }

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
