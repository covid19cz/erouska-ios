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
    
    var platform: BTPlatform? {
        get {
            BTPlatform(rawValue: _platform)
        }
        set {
            guard let platform = newValue else { return }
            _platform = platform.rawValue
        }
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    convenience init(device: BTScan, avargeRssi: Int, medianRssi: Int, startDate: Date, endDate: Date) {
        self.init()
        
        self.id = UUID().uuidString
        self.bluetoothIdentifier = device.bluetoothIdentifier.uuidString
        self.deviceIdentifier = device.deviceIdentifier
        self.buid = device.backendIdentifier ?? ""
        self.platform = device.platform
        self.name = device.name

        self.startDate = startDate
        self.endDate = endDate
        self.avargeRssi = avargeRssi
        self.medianRssi = medianRssi
    }
    
    func toScan() -> Scan {
        Scan(
            id: self.id,
            bluetoothIdentifier: self.bluetoothIdentifier,
            deviceIdentifier: self.deviceIdentifier,
            buid: self.buid,
            platform: self.platform ?? .iOS, // Adding defuault `.iOS` rather then failing whole mapping
            name: self.name ?? "neznámé",
            date: self.startDate,
            rssi: self.avargeRssi,
            medianRssi: self.medianRssi,
            state: .intial
        )
    }
    
}
