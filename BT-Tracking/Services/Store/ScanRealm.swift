//
//  ScanRealm.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift

final class ScanRealm: Object {
    @objc dynamic var id = ""
    @objc dynamic var bluetoothIdentifier = ""
    @objc dynamic var deviceIdentifier = ""
    @objc dynamic var buid = ""
    @objc dynamic var _platform = ""
    @objc dynamic var name: String?
    @objc dynamic var startDate = Date()
    @objc dynamic var endDate = Date()
    @objc dynamic var avargeRssi = 0
    @objc dynamic var medianRssi = 0

    var platform: BTDevice.Platform? {
        get {
            BTDevice.Platform(rawValue: _platform)
        }
        set {
            guard let platform = newValue else { return }
            _platform = platform.rawValue
        }
    }

    override class func primaryKey() -> String {
        "id"
    }

    convenience init(device: BTDevice, avargeRssi: Int, medianRssi: Int, startDate: Date, endDate: Date) {
        self.init()

        id = UUID().uuidString
        bluetoothIdentifier = device.bluetoothIdentifier.uuidString
        deviceIdentifier = device.deviceIdentifier
        buid = device.backendIdentifier ?? ""
        platform = device.platform
        name = device.name

        self.startDate = startDate
        self.endDate = endDate
        self.avargeRssi = avargeRssi
        self.medianRssi = medianRssi
    }

    func toScan() -> Scan {
        Scan(
            id: id,
            bluetoothIdentifier: bluetoothIdentifier,
            deviceIdentifier: deviceIdentifier,
            buid: buid,
            platform: platform ?? .iOS, // Adding defuault `.iOS` rather then failing whole mapping
            name: name ?? "neznámé",
            date: startDate,
            rssi: avargeRssi,
            medianRssi: medianRssi)
    }
}
