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
    let date: Date
    var name: String?
    var rssi: Int
}

extension BTDevice: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.backendIdentifier == rhs.backendIdentifier
    }
}
