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
    let bluetoothIdentifier: UUID // CBPeripheral identifier
    let backendIdentifier: String? // buid
    let platform: Platform
    var date: Date
    var name: String?
    var rssi: Int
    
    func toDeviceScan(with uuid: String? = nil) -> DeviceScan {
        DeviceScan(
            id: uuid ?? UUID().uuidString,
            bluetoothIdentifier: self.bluetoothIdentifier.uuidString,
            buid: self.backendIdentifier ?? "Unknown",
            platform: self.platform,
            name: self.name ?? "Unknown",
            date: self.date,
            rssi: self.rssi
        )
    }    
}

extension BTDevice: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.backendIdentifier == rhs.backendIdentifier
    }
}
