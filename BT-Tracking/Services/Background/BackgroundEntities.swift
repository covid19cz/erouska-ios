//
//  BackgroundEntities.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 17/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

enum BackgroundTaskIdentifier: String, CaseIterable {

    // only one task identifier is allowed have the .exposure-notification suffix
    case exposureNotification = "exposure-notification"

    var schedulerIdentifier: String {
        guard let bundleID = Bundle.main.bundleIdentifier else { return "invalid-task-id!" }
        return "\(bundleID).\(rawValue)"
    }

}
