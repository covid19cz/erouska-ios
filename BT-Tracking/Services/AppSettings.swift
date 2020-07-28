//
//  AppSettings.swift
// eRouska
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct AppSettings {

    private enum Keys: String {
        case appState
        case backgroundModeAlertShown
        case appFirstTimeLaunched
        case lastUploadDate
        case lastDataPurgeDate
        case eHRID
    }

    static let firebaseRegion = "europe-west1"
    
    static let TUIDRotation: Int = 60 * 60

    static var state: ActiveAppVM.State? {
        get {
            return ActiveAppVM.State(rawValue: string(forKey: .appState))
        }
        set {
            set(withKey: .appState, value: newValue?.rawValue)
        }
    }

    static var lastUploadDate: Date? {
        get {
            let rawValue = double(forKey: .lastUploadDate)
            return Date(timeIntervalSince1970: TimeInterval(rawValue))
        }
        set {
            set(withKey: .lastUploadDate, value: newValue?.timeIntervalSince1970)
        }
    }

    static var lastPurgeDate: Date? {
        get {
            let rawValue = double(forKey: .lastDataPurgeDate)
            return Date(timeIntervalSince1970: TimeInterval(rawValue))
        }
        set {
            set(withKey: .lastDataPurgeDate, value: newValue?.timeIntervalSince1970)
        }
    }
    
    static var backgroundModeAlertShown: Bool {
        get {
            return bool(forKey: .backgroundModeAlertShown)
        }
        set {
            set(withKey: .backgroundModeAlertShown, value: newValue)
        }
    }
    
    static var appFirstTimeLaunched: Bool {
        get {
            return bool(forKey: .appFirstTimeLaunched)
        }
        set {
            set(withKey: .appFirstTimeLaunched, value: newValue)
        }
    }

    static var eHRID: String? {
        get {
            let value = string(forKey: .eHRID)
            return value.isEmpty ? nil : value
        }
        set {
            set(withKey: .eHRID, value: newValue)
        }
    }

    static func deleteAllData() {
        AppSettings.state = nil
        AppSettings.lastUploadDate = nil
        AppSettings.backgroundModeAlertShown = false
        AppSettings.eHRID = nil
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
