//
//  ScanRealm.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift

class ScanRealm: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var bluetoothIdentifier = ""
    @objc dynamic var buid = ""
    @objc dynamic var _platform = ""
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    @objc dynamic var rssi = 0
    
    var platform: BTDevice.Platform? {
        get {
            BTDevice.Platform.init(rawValue: _platform)
        }
        set {
            guard let platform = newValue else { return }
            _platform = platform.rawValue
        }
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    convenience init(device: Scan) {
        self.init()
        
        self.id = device.id
        self.bluetoothIdentifier = device.bluetoothIdentifier
        self.buid = device.buid
        self.platform = device.platform
        self.name = device.name
        self.date = device.date
        self.rssi = device.rssi
    }
    
    func toScan() -> Scan {
        Scan(
            id: self.id,
            bluetoothIdentifier: self.bluetoothIdentifier,
            buid: self.buid,
            platform: self.platform ?? .iOS, // Adding defuault `.iOS` rather then failing whole mapping
            name: self.name,
            date: self.date,
            rssi: self.rssi
        )
    }
}
