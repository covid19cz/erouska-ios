//
//  AppSettings.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct AppSettings {

    static let firebaseRegion = "europe-west1"

    static let backgroundModeAlertShownKey = "backgroundModeAlertShown"

    static let TUIDRotation: Int = 60 * 60

    static var state: ActiveAppViewModel.State? {
        get {
            return ActiveAppViewModel.State(rawValue: UserDefaults.standard.string(forKey: "AppState") ?? "")
        }
        set {
            UserDefaults.standard.setValue(newValue?.rawValue, forKey: "AppState")
        }
    }

    static var lastUploadDate: Date? {
        get {
            let rawValue = UserDefaults.standard.double(forKey: "UploadDate")
            let time = TimeInterval(rawValue)
            return Date(timeIntervalSince1970: time)
        }
        set {
            UserDefaults.standard.set(newValue?.timeIntervalSince1970, forKey: "UploadDate")
        }
    }
    
    static var backgroundModeAlertShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: backgroundModeAlertShownKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: backgroundModeAlertShownKey)
        }
    }

    static func deleteAllData() {
        KeychainService.BUID = nil
        KeychainService.TUIDs = nil
        
        AppSettings.state = nil
        AppSettings.lastUploadDate = nil
        AppSettings.backgroundModeAlertShown = false
    }
}
