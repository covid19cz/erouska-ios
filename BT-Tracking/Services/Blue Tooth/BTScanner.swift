//
//  BTScanner.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BTScannering: class {

    var delegate: BTScannerDelegate? { get set }
    
    var isRunning: Bool { get }
    func start()
    func stop()

}

protocol BTScannerDelegate: class {
    func didFound(device: CBPeripheral, RSSI: Int)
    func didUpdate(device: CBPeripheral, RSSI: Int)

    func didReadData(for device: CBPeripheral, data: Data)
}

protocol BTScannerStoreDelegate: class {
    func didFind(device: BTDevice)
    func didUpdate(device: BTDevice)
}

final class BTScanner: NSObject, BTScannering, CBCentralManagerDelegate, CBPeripheralDelegate {

    var deviceUpdateLimit: TimeInterval = 4 // in seconds

    var filterRSSIPower: Bool = false
    private let allowedRSSIRange: ClosedRange<Int> = -90...0

    private var centralManager: CBCentralManager! = nil
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    private var discoveredDevices: [BTDevice] = []
    private var discoveredData: [UUID: Data] = [:]
    private var discoveredRefresh: [UUID: TimeInterval] = [:]

    private let acceptUUIDs = [BT.broadcastCharacteristic.cbUUID, BT.transferCharacteristic.cbUUID]
    
    var scannerStoreDelegate: BTScannerStoreDelegate?

    override init() {
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)

        if #available(iOS 13.1, *) {
            if ![CBManagerAuthorization.allowedAlways, .restricted].contains(CBCentralManager.authorization) {
                log("BTScanner: Not authorized! \(CBCentralManager.authorization)")
                return
            }
        } else if #available(iOS 13.0, *) {
            if ![CBManagerAuthorization.allowedAlways, .restricted].contains(centralManager.authorization) {
                log("BTScanner: Not authorized! \(centralManager.authorization)")
                return
            }
        }
    }

    // MARK: - BTScannering

    weak var delegate: BTScannerDelegate?

    var isRunning: Bool {
        return centralManager.isScanning
    }
    private var started: Bool = false

    func start() {
        started = true
        guard !centralManager.isScanning, centralManager.state == .poweredOn else { return }

        centralManager.scanForPeripherals(
            withServices: [BT.transferService.cbUUID],
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ]
        )
        log("BTScanner: Scanning started")
    }

    func stop() {
        started = false

        discoveredPeripherals.removeAll()
        discoveredDevices.removeAll()
        discoveredData.removeAll()
        discoveredRefresh.removeAll()

        guard centralManager.isScanning else { return }

        centralManager.stopScan()
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("BTScanner: centralManagerDidUpdateState: \(central.state.rawValue)")

        guard central.state == .poweredOn else { return }

        guard started else { return }
        start()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard discoveredPeripherals[peripheral.identifier] == nil else {
            // already registred
            
            // limit refresh
            if let timeInterval = discoveredRefresh[peripheral.identifier], timeInterval + deviceUpdateLimit > Date.timeIntervalSinceReferenceDate {
                return
            }
            discoveredRefresh[peripheral.identifier] = Date.timeIntervalSinceReferenceDate

            log("BTScanner: Update ID: \(peripheral.identifier.uuidString) at \(RSSI)")
            delegate?.didUpdate(device: peripheral, RSSI: RSSI.intValue)

            // update device RSII or name
            if let index = discoveredDevices.firstIndex(where: { $0.bluetoothIdentifier == peripheral.identifier }) {
                var device = discoveredDevices[index]
                device.rssi = RSSI.intValue
                device.name = peripheral.name ?? device.name
                discoveredDevices[index] = device

                scannerStoreDelegate?.didUpdate(device: device)
            }

            return
        }
        log("BTScanner: Discovered \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")

        delegate?.didFound(device: peripheral, RSSI: RSSI.intValue)

        if filterRSSIPower {
            guard allowedRSSIRange.contains(RSSI.intValue) else {
                log("BTScanner: RSSI range \(RSSI.intValue)")
                return
            }
        }
        let device: BTDevice

        // get BUID for android if not, we try to look as andorid
        if peripheral.name == nil || advertisementData["kCBAdvDataServiceData"] != nil {
            // probably android
            var BUID: String?
            var replaceDevice: BTDevice?

            // find buid in service data
            if let serviceData = advertisementData["kCBAdvDataServiceData"] as? [CBUUID: Any],
                let rawBUID = serviceData[CBUUID(string: "DD68")] as? Data,
                let raw = String(bytes: rawBUID, encoding: .utf8) {

                // check if we already have this buid
                if let oldIndex = discoveredDevices.firstIndex(where: { $0.backendIdentifier == raw }) {
                    // if yes we need update device id and maybe name
                    let oldDevice = discoveredDevices[oldIndex]
                    replaceDevice = oldDevice

                    discoveredDevices.remove(at: oldIndex)
                    discoveredPeripherals.removeValue(forKey: oldDevice.bluetoothIdentifier)
                }
                BUID = raw
            } else {
                // ignore device without buid
                return
            }

            device = BTDevice(
                id: replaceDevice?.id ?? UUID(),
                bluetoothIdentifier: peripheral.identifier,
                backendIdentifier: BUID,
                platform: .android,
                date: replaceDevice?.date ?? Date(),
                name: peripheral.name ?? replaceDevice?.name,
                rssi: RSSI.intValue
            )

            if replaceDevice != nil {
                discoveredDevices.append(device)
                scannerStoreDelegate?.didUpdate(device: device)
                return
            }
        } else {
            // probably iOS
            device = BTDevice(
                id: UUID(),
                bluetoothIdentifier: peripheral.identifier,
                backendIdentifier: nil,
                platform: .iOS,
                date: Date(),
                name: peripheral.name,
                rssi: RSSI.intValue
            )

            discoveredData[peripheral.identifier] = Data()
        }
        discoveredPeripherals[peripheral.identifier] = peripheral

        log("BTScanner: Found \(device.platform) device \(device)")
        scannerStoreDelegate?.didFind(device: device)
        discoveredDevices.append(device)

        if device.platform == .iOS, device.backendIdentifier == nil {
            log("BTScanner: Connecting to peripheral \(peripheral)")
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log("BTScanner: Failed to connect to \(peripheral), error: \(error?.localizedDescription ?? "none")")

        cleanup(peripheral)
        discoveredPeripherals.removeValue(forKey: peripheral.identifier)
    }

    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        log("BTScanner: connectionEventDidOccur \(peripheral), event: \(event)")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("BTScanner: Peripheral connected \(peripheral)")

        peripheral.delegate = self
        peripheral.discoverServices([BT.transferService.cbUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log("BTScanner: didDisconnectPeripheral: \(peripheral), error: \(error?.localizedDescription ?? "none")")

        cleanup(peripheral)
    }

    // MARK: CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            log("BTScanner: Error discovering services: \(String(describing: error?.localizedDescription))")
            cleanup()
            return
        }

        // Discover the characteristic we want...
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let services = peripheral.services, !services.isEmpty else {
            log("BTScanner: No services to discover")
            return
        }

        services.forEach {
            peripheral.discoverCharacteristics([BT.transferCharacteristic.cbUUID], for: $0) // transferCharacteristic
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            log("BTScanner: Error discovering characteristics \(String(describing: error?.localizedDescription))")
            cleanup()
            return
        }

        guard let characteristics = service.characteristics else {
            log("BTScanner: No characteristics to subscribe")
            return
        }

        for characteristic in characteristics where acceptUUIDs.contains(characteristic.uuid) {
            log("BTScanner: readValue for \(characteristic.uuid)")
            peripheral.readValue(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            log("BTScanner: Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        guard let newData = characteristic.value else {
            log("BTScanner: No data in characteristic")
            return
        }

        peripheral.setNotifyValue(false, for: characteristic)
        centralManager.cancelPeripheralConnection(peripheral)

        let stringFromData = String(data: newData, encoding: .utf8)
        delegate?.didReadData(for: peripheral, data: newData)
        log("BTScanner: Received: \(stringFromData ?? "none")")

        // set guid
        if let index = discoveredDevices.firstIndex(where: { $0.bluetoothIdentifier == peripheral.identifier }) {
            let oldDevice = discoveredDevices[index]
            let device = BTDevice(
                id: oldDevice.id,
                bluetoothIdentifier: peripheral.identifier,
                backendIdentifier: stringFromData,
                platform: .iOS,
                date: oldDevice.date,
                name: peripheral.name ?? oldDevice.name,
                rssi: oldDevice.rssi
            )

            discoveredDevices[index] = device
            scannerStoreDelegate?.didUpdate(device: device)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            log("BTScanner: Error changing notification state: \(String(describing: error?.localizedDescription))")
            return
        }

        guard acceptUUIDs.contains(characteristic.uuid) else {
            log("BTScanner: Error not accepted characteristic: \(characteristic)")
            return
        }

        if characteristic.isNotifying {
            log("BTScanner: Notification began on \(characteristic)")
        } else {
            log("BTScanner: Notification stoppped on \(characteristic). Disconnecting")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

}

private extension BTScanner {

    func cleanup() {
        for peripheral in discoveredPeripherals {
            cleanup(peripheral.value)
        }
        discoveredPeripherals = [:]
        discoveredData = [:]
    }

    func cleanup(_ peripheral: CBPeripheral) {
        // Don't do anything if we're not connected
        // See if we are subscribed to a characteristic on the peripheral
        guard peripheral.state == .connected, let services = peripheral.services else { return }

        for service in services where service.characteristics != nil {
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics where acceptUUIDs.contains(characteristic.uuid) {
                guard !characteristic.isNotifying else { return }
                peripheral.setNotifyValue(false, for: characteristic)
            }
        }
    }

}
