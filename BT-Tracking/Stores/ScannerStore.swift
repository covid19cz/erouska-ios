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

final class ScannerStore {

    let scans = BehaviorRelay<[Scan]>(value: [])

    private func scan(from device: BTDevice) -> Scan {
        return Scan(
            id: device.id,
            bluetoothIdentifier: device.bluetoothIdentifier.uuidString,
            buid: device.backendIdentifier ?? "neznámý",
            platform: device.platform,
            name: device.name ?? "neznámý",
            date: device.date,
            rssi: device.rssi
        )
    }

}

extension ScannerStore: BTScannerDelegate {

    func didFind(device: BTDevice) {
        let updatedScans = scans.value + [scan(from: device)]
        scans.accept(updatedScans)
    }

    func didUpdate(device: BTDevice) {
        let scan = self.scan(from: device)
        let updatedScans: [Scan]
        if let oldIndex = scans.value.firstIndex(where: { $0.id == device.id }) {
            var updated = scans.value
            updated[oldIndex] = scan
            updatedScans = updated
        } else {
            updatedScans = scans.value + [scan]
        }
        scans.accept(updatedScans)
    }

}
