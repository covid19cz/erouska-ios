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

    static var BUID: String? {
        get {
            return UserDefaults.standard.string(forKey: "BUID")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BUID")
        }
    }

    static var TUIDs: [String]? {
        get {
            return UserDefaults.standard.object(forKey: "TUIDs") as? [String]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "TUIDs")
        }
    }

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

    static func deleteAllData() {
        AppSettings.BUID = nil
        AppSettings.TUIDs = nil
        AppSettings.state = nil
        AppSettings.lastUploadDate = nil
    }

}
