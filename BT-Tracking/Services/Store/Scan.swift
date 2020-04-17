//
//  DeviceScan.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct Scan: Equatable {
    let id: String
    
    let bluetoothIdentifier: String
    let deviceIdentifier: String
    let buid: String
    let platform: BTPlatform
    let name: String
    let date: Date
    let rssi: Int
    let medianRssi: Int?
    let state: BTScanDevice.State

    enum ExpositionLevel: Int {
        case level1
        case level2
        case level3
        case level4
        case level5
        case level6
        case level7
        case level8
    }

    var expositionLevel: ExpositionLevel {
        let criticalExpositionRssi = RemoteValues.criticalExpositionRssi

        switch rssi {
        case criticalExpositionRssi...: return .level8
        case (criticalExpositionRssi - 5)...: return .level7
        case (criticalExpositionRssi - 10)...: return .level6
        case (criticalExpositionRssi - 15)...: return .level5
        case (criticalExpositionRssi - 17)...: return .level4
        case (criticalExpositionRssi - 19)...: return .level3
        case (criticalExpositionRssi - 21)...: return .level2
        default: return .level1
        }
    }

}
