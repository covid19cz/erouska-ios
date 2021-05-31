//
//  ActiveAppState.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 05.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import Foundation

enum ActiveAppState: String {
    case enabled
    case paused
    case disabledBluetooth = "disabled"
    case disabledExposures
}
