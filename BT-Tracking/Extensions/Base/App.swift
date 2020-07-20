//
//  Meta.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 17/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct App {
    static var appVersion: Version {
        let rawValue = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return Version(rawValue ?? "")
    }

    static var bundleBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }
}
