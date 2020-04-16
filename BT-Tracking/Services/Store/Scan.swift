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
}
