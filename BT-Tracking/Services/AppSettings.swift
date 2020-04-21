//
//  AppSettings.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct AppSettings {

    private enum Keys: String {
        case appState = "appState"
        case backgroundModeAlertShown = "backgroundModeAlertShown"
        case appFirstTimeLaunched = "appFirstTimeLaunched"
        case lastUploadDate = "lastUploadDate"
        case lastDataPurgeDate = "lastDataPurgeDate"
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
            let time = TimeInterval(rawValue)
            return Date(timeIntervalSince1970: time)
        }
        set {
            set(withKey: .lastUploadDate, value: newValue?.timeIntervalSince1970)
        }
    }

    static var lastPurgeDate: Date? {
        get {
            let rawValue = double(forKey: .lastDataPurgeDate)
            let time = TimeInterval(rawValue)
            return Date(timeIntervalSince1970: time)
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

    static func deleteAllData() {
        KeychainService.BUID = nil
        KeychainService.TUIDs = nil
        
        AppSettings.state = nil
        AppSettings.lastUploadDate = nil
        AppSettings.backgroundModeAlertShown = false
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
