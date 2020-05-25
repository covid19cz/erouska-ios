//
//  BTDevice.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct BTScan {
    let id: UUID
    var deviceIdentifier: String
    let bluetoothIdentifier: UUID // CBPeripheral identifier, on android is very random
    var backendIdentifier: String? // buid
    var platform: BTPlatform
    var date: Date
    var name: String?
    var rssi: Int
    var medianRssi: Int?
    var state: BTScanDevice.State

    init(id: UUID,
         bluetoothIdentifier: UUID,
         backendIdentifier: String? = nil,
         platform: BTPlatform,
         date: Date,
         name: String? = nil,
         rssi: Int,
         medianRssi: Int? = nil,
         state: BTScanDevice.State = .intial) {
        self.id = id
        if platform == .android {
            self.deviceIdentifier = backendIdentifier ?? bluetoothIdentifier.uuidString
        } else {
            self.deviceIdentifier = bluetoothIdentifier.uuidString
        }
        self.bluetoothIdentifier = bluetoothIdentifier
        self.backendIdentifier = backendIdentifier
        self.platform = platform
        self.date = date
        self.name = name
        self.rssi = rssi
        self.medianRssi = medianRssi
        self.state = state
    }
    
    func toScan(with uuid: String? = nil) -> Scan {
        Scan(
            id: uuid ?? UUID().uuidString,
            bluetoothIdentifier: self.bluetoothIdentifier.uuidString,
            deviceIdentifier: self.deviceIdentifier,
            buid: self.backendIdentifier ?? "unknown",
            platform: self.platform,
            name: self.name ?? self.platform.rawValue,
            date: self.date,
            rssi: self.rssi,
            medianRssi: self.medianRssi,
            state: self.state
        )
    }    
}

extension BTScan: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.backendIdentifier == rhs.backendIdentifier
    }
}
