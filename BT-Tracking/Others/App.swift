//
//  Meta.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 17/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct App {
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    static var bundleBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }
}
