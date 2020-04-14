//
//  BTDevice.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct BTDevice {
    enum Platform: String {
        case iOS, android = "Android"
    }

    let id: UUID
    var deviceIdentifier: String
    let bluetoothIdentifier: UUID // CBPeripheral identifier, on android is very random
    var backendIdentifier: String? // buid
    var platform: Platform
    var date: Date
    var name: String?
    var rssi: Int
    var medianRssi: Int?

    init(id: UUID,
         bluetoothIdentifier: UUID,
         backendIdentifier: String? = nil,
         platform: BTDevice.Platform,
         date: Date,
         name: String? = nil,
         rssi: Int,
         medianRssi: Int? = nil) {
        self.id = id
        if platform == .android {
            deviceIdentifier = backendIdentifier ?? bluetoothIdentifier.uuidString
        } else {
            deviceIdentifier = bluetoothIdentifier.uuidString
        }
        self.bluetoothIdentifier = bluetoothIdentifier
        self.backendIdentifier = backendIdentifier
        self.platform = platform
        self.date = date
        self.name = name
        self.rssi = rssi
        self.medianRssi = medianRssi
    }

    func toScan(with uuid: String? = nil) -> Scan {
        Scan(
            id: uuid ?? UUID().uuidString,
            bluetoothIdentifier: bluetoothIdentifier.uuidString,
            deviceIdentifier: deviceIdentifier,
            buid: backendIdentifier ?? "unknown",
            platform: platform,
            name: name ?? platform.rawValue,
            date: date,
            rssi: rssi,
            medianRssi: medianRssi)
    }
}

extension BTDevice: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.backendIdentifier == rhs.backendIdentifier
    }
}
