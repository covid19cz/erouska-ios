//
//  AppSettings.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import FirebaseAuth

struct AppSettings {

    enum Keys: String {
        case appState
        case appFirstTimeLaunched

        case efgsEnabled

        case backgroundModeAlertShown

        case lastProcessedFileNames
        case lastProcessedDate
        case lastUploadDate

        case lastExposureWarningId
        case lastExposureWarningDate
        case lastExposureWarningClosed
        case lastExposureWarningInfoDisplayed
        case lastExposureWarningNotDisplayed

        case v2_0NewsLaunched
        case v2_3NewsLaunched

        case lastLegacyDataFetchDate
        case currentDataLastFetchDate

        case howItWorksClosed

        case activated = "activated2"

        case sendReport
    }

    /// Firebase Region
    static let firebaseRegion = "europe-west1"

    /// Last application state (paused, running, ...)
    static var state: ActiveAppVM.State? {
        get {
            ActiveAppVM.State(rawValue: string(forKey: .appState))
        }
        set {
            set(withKey: .appState, value: newValue?.rawValue)
        }
    }

    /// Check if it's first time launch
    static var appFirstTimeLaunched: Bool {
        get {
            bool(forKey: .appFirstTimeLaunched)
        }
        set {
            set(withKey: .appFirstTimeLaunched, value: newValue)
        }
    }

    /// If background mode off alert was shown
    static var backgroundModeAlertShown: Bool {
        get {
            bool(forKey: .backgroundModeAlertShown)
        }
        set {
            set(withKey: .backgroundModeAlertShown, value: newValue)
        }
    }

    /// If efgs is enabled
    static var efgsEnabled: Bool {
        get {
            bool(forKey: .efgsEnabled)
        }
        set {
            set(withKey: .efgsEnabled, value: newValue)
        }
    }

    /// Last processed file name [country code: file name]
    static var lastProcessedFileNames: ReportServicing.ProcessedFileNames {
        get {
            dictionary(forKey: .lastProcessedFileNames).compactMapValues { $0 as? String }
        }
        set {
            set(withKey: .lastProcessedFileNames, value: newValue)
        }
    }

    /// When was last processed time
    static var lastProcessedDate: Date? {
        get {
            date(forKey: .lastProcessedDate)
        }
        set {
            setDate(forKey: .lastProcessedDate, date: newValue)
        }
    }

    /// When it app last time uploaded keys
    static var lastUploadDate: Date? {
        get {
            date(forKey: .lastUploadDate)
        }
        set {
            setDate(forKey: .lastUploadDate, date: newValue)
        }
    }

    /// Last shown exposure warning id
    static var lastExposureWarningId: String? {
        get {
            string(forKey: .lastExposureWarningId)
        }
        set {
            set(withKey: .lastExposureWarningId, value: newValue)
        }
    }

    /// When app last showed notification about exposure
    static var lastExposureWarningDate: Date? {
        get {
            date(forKey: .lastExposureWarningDate)
        }
        set {
            setDate(forKey: .lastExposureWarningDate, date: newValue)
        }
    }

    /// If user closed last show exposure warning
    static var lastExposureWarningClosed: Bool {
        get {
            bool(forKey: .lastExposureWarningClosed)
        }
        set {
            set(withKey: .lastExposureWarningClosed, value: newValue)
        }
    }

    /// If user saw detail information about exposure
    static var lastExposureWarningInfoDisplayed: Bool {
        get {
            bool(forKey: .lastExposureWarningInfoDisplayed)
        }
        set {
            set(withKey: .lastExposureWarningInfoDisplayed, value: newValue)
        }
    }

    /// If user user din't saw exposure in app yet
    static var lastExposureWarningNotDisplayed: Bool {
        get {
            bool(forKey: .lastExposureWarningNotDisplayed)
        }
        set {
            set(withKey: .lastExposureWarningNotDisplayed, value: newValue)
        }
    }

    /// Check if it's migration to new version
    static var v2_0NewsLaunched: Bool {
        get {
            bool(forKey: .v2_0NewsLaunched)
        }
        set {
            set(withKey: .v2_0NewsLaunched, value: newValue)
        }
    }

    /// Check if it's migration to efgs version
    static var v2_3NewsLaunched: Bool {
        get {
            bool(forKey: .v2_3NewsLaunched)
        }
        set {
            set(withKey: .v2_3NewsLaunched, value: newValue)
        }
    }

    /// Migrated from pre sectioned list date
    static var lastLegacyDataFetchDate: Date? {
        get {
            date(forKey: .lastLegacyDataFetchDate)
        }
        set {
            setDate(forKey: .lastLegacyDataFetchDate, date: newValue)
        }
    }

    /// Last time when app fetched current data
    static var currentDataLastFetchDate: Date? {
        get {
            date(forKey: .currentDataLastFetchDate)
        }
        set {
            setDate(forKey: .currentDataLastFetchDate, date: newValue)
        }
    }

    /// If current customToken value from Keychain is activated or needs to reactivate.
    /// Using this value for handling app reinstallation.
    static var activated: Bool {
        get {
            bool(forKey: .activated)
        }
        set {
            set(withKey: .activated, value: newValue)
        }
    }

    /// If user closed how it works banner
    static var howItWorksClosed: Bool {
        get {
            bool(forKey: .howItWorksClosed)
        }
        set {
            set(withKey: .howItWorksClosed, value: newValue)
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

    // MARK: - Private

    private static func bool(forKey key: Keys) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }

    private static func double(forKey key: Keys) -> Double {
        return UserDefaults.standard.double(forKey: key.rawValue)
    }

    private static func string(forKey key: Keys) -> String {
        return UserDefaults.standard.string(forKey: key.rawValue) ?? ""
    }

    private static func dictionary(forKey key: Keys) -> [String: Any] {
        return UserDefaults.standard.dictionary(forKey: key.rawValue) ?? [:]
    }

    private static func data(forKey key: Keys) -> Data? {
        return UserDefaults.standard.data(forKey: key.rawValue)
    }

    private static func date(forKey key: Keys) -> Date? {
        let rawValue = double(forKey: key)
        guard rawValue != 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(rawValue))
    }

    private static func set(withKey key: Keys, value: Any?) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    private static func setDate(forKey key: Keys, date: Date?) {
        set(withKey: key, value: date?.timeIntervalSince1970)
    }

}
