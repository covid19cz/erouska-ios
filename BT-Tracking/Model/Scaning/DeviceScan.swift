//
//  DeviceScan.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct DeviceScan {
    enum Platform: String {
        case iOS, android = "Android"
    }

    let id = UUID().uuidString

    let bluetoothIdentifier: String
    let buid: String
    let platform: Platform
    let name: String
    let date: Date
    let rssi: Int
}
