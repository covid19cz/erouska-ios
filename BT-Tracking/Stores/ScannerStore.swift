//
//  ScannerStore.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxSwift
import RxCocoa
import RealmSwift

class ScannerStore: BTScannerStoreDelegate {

    let scans = BehaviorRelay<[DeviceScan]>(value: [])
    let storedScans = BehaviorRelay<[DeviceScan]>(value: [])
    
    private let realm = try! Realm()
    private var storedScansToken: NotificationToken!
    
    init() {
        storedScansToken = realm.objects(DeviceScanRealm.self).observe { [weak self] _ in
            guard let self = self else { return }
            let scans: [DeviceScan] = self.realm.objects(DeviceScanRealm.self).map { $0.toDeviceScan() }
            self.storedScans.accept(scans)
       }
    }
    
    func didFind(device: CBPeripheral, rssi: Int) {
        let scan = DeviceScan(
            bluetoothIdentifier: device.identifier.uuidString,
            buid: "",
            platform: .iOS,
            name: device.name ?? "Unknown",
            date: Date(),
            rssi: rssi
        )
        addDeviceToStorage(device: scan)
    }
    
    private func addDeviceToStorage(device: DeviceScan) {
        let storageData = DeviceScanRealm(device: device)
        try! realm.write {
            realm.add(storageData, update: .all)
        }
        let updatedScans = scans.value + [device]
        scans.accept(updatedScans)
    }
}
