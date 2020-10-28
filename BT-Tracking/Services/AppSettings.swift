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

    private enum Keys: String {
        case appState
        case appFirstTimeLaunched
        case backgroundModeAlertShown

        case lastProcessedFileName
        case lastProcessedDate
        case lastUploadDate

        case lastExposureWarningId
        case lastExposureWarningClosed
        case lastExposureWarningInfoDisplayed

        case v2_0NewsLaunched

        case lastLegacyDataFetchDate
        case currentDataLastFetchDate

        case activated = "activated2"
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

    /// Last processed file name
    static var lastProcessedFileName: String? {
        get {
            string(forKey: .lastProcessedFileName)
        }
        set {
            set(withKey: .lastProcessedFileName, value: newValue)
        }
    }

    /// When was last processed time
    static var lastProcessedDate: Date? {
        get {
            let rawValue = double(forKey: .lastProcessedDate)
            guard rawValue != 0 else { return nil }
            return Date(timeIntervalSince1970: TimeInterval(rawValue))
        }
        set {
            set(withKey: .lastProcessedDate, value: newValue?.timeIntervalSince1970)
        }
    }

    /// When it app last time uploaded keys
    static var lastUploadDate: Date? {
        get {
            let rawValue = double(forKey: .lastUploadDate)
            guard rawValue != 0 else { return nil }
            return Date(timeIntervalSince1970: TimeInterval(rawValue))
        }
        set {
            set(withKey: .lastUploadDate, value: newValue?.timeIntervalSince1970)
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

    /// Check if it's migration to new version
    static var v2_0NewsLaunched: Bool {
        get {
            bool(forKey: .v2_0NewsLaunched)
        }
        set {
            set(withKey: .v2_0NewsLaunched, value: newValue)
        }
    }

    /// Migrated from pre sectioned list date
    static var lastLegacyDataFetchDate: Date? {
        get {
            let rawValue = double(forKey: .lastLegacyDataFetchDate)
            guard rawValue != 0 else { return nil }
            return Date(timeIntervalSince1970: TimeInterval(rawValue))
        }
        set {
            set(withKey: .lastLegacyDataFetchDate, value: newValue?.timeIntervalSince1970)
        }
    }

    /// Last time when app fetched current data
    static var currentDataLastFetchDate: Date? {
        get {
            let rawValue = double(forKey: .currentDataLastFetchDate)
            guard rawValue != 0 else { return nil }
            return Date(timeIntervalSince1970: TimeInterval(rawValue))
        }
        set {
            set(withKey: .currentDataLastFetchDate, value: newValue?.timeIntervalSince1970)
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

    /// Cleanup data after logout
    static func deleteAllData() {
        KeychainService.token = nil

        activated = false

        backgroundModeAlertShown = false

        state = nil

        lastProcessedFileName = nil
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

    private static func set(withKey key: Keys, value: Any?) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

}
