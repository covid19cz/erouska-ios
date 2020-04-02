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

    /// default: 3, in seconds
    var deviceUpdateLimit: TimeInterval { get set }
    /// default: -90...0, in RSSI
    var filterRSSIPower: Bool { get set }
    /// default: 60, in seconds
    var fetchBUIDRetry: TimeInterval { get set }

    func add(delegate: BTScannerDelegate)
    func remove(delegate: BTScannerDelegate)

    var state: CBManagerState { get }
    typealias UpdateState = (_ state: CBManagerState) -> Void
    var didUpdateState: UpdateState? { get set }

    var isRunning: Bool { get }
    func start()
    func stop()

}

protocol BTScannerDelegate: class {
    func didFind(device: BTDevice)
    func didUpdate(device: BTDevice)
}

final class BTScanner: MulticastDelegate<BTScannerDelegate>, BTScannering, CBCentralManagerDelegate, CBPeripheralDelegate {

    private var centralManager: CBCentralManager! = nil
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    private var discoveredDevices: [BTDevice] = []
    private var discoveredData: [UUID: Data] = [:]
    private var discoveredRefresh: [UUID: TimeInterval] = [:]

    private var retryBUID: [UUID: TimeInterval] = [:]

    private let acceptUUIDs = [BT.broadcastCharacteristic.cbUUID, BT.transferCharacteristic.cbUUID]

    override init() {
        super.init()

        centralManager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: [
                CBCentralManagerOptionShowPowerAlertKey: false,
            ]
        )

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

    var deviceUpdateLimit: TimeInterval = 3 // in seconds
    private var reportedBackground: Bool = false

    var filterRSSIPower: Bool = false
    private let allowedRSSIRange: ClosedRange<Int> = -100...0

    var fetchBUIDRetry: TimeInterval = 30

    var isRunning: Bool {
        return centralManager.isScanning
    }
    private var started: Bool = false

    var state: CBManagerState {
        return centralManager.state
    }
    var didUpdateState: UpdateState?

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

        didUpdateState?(central.state)

        guard central.state == .poweredOn else { return }

        guard started else { return }
        start()
    }

    private func checkRefreshTime(UUID: UUID) -> Bool {
        guard let timeInterval = discoveredRefresh[UUID] else { return false }
        guard !AppDelegate.inBackground else {
            if !reportedBackground {
                log("Background refresh limit Disabled")
            }
            reportedBackground = true
            return false
        }
        reportedBackground = false
        return timeInterval + deviceUpdateLimit > Date.timeIntervalSinceReferenceDate
    }

    func checkDeviceType(peripheral: CBPeripheral, advertisementData: [String : Any]) -> BTDevice.Platform {
        return advertisementData["kCBAdvDataServiceData"] == nil ? .iOS : .android
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard discoveredPeripherals[peripheral.identifier] == nil else {
            // already registred

            // limit refresh
            guard !checkRefreshTime(UUID: peripheral.identifier) else {
                //log("Check refresh time guarded")
                return
            }
            log("BTScanner: Update ID: \(peripheral.identifier.uuidString) at \(RSSI)")
            discoveredRefresh[peripheral.identifier] = Date.timeIntervalSinceReferenceDate

            // update device RSII or name
            guard let index = discoveredDevices.firstIndex(where: { $0.bluetoothIdentifier == peripheral.identifier }) else {
                log("BTScanner: Update device RSSI or name guarded")
                return
            }

            var device = discoveredDevices[index]
            device.rssi = RSSI.intValue
            device.name = peripheral.name ?? device.name
            device.date = Date()

            // try to get again BUID
            if let retry = retryBUID[peripheral.identifier], retry + 60 < Date().timeIntervalSince1970 {
                log("BTScanner: Trying get again BUID for: \(peripheral.identifier.uuidString) with data: \(advertisementData)")

                let platform = checkDeviceType(peripheral: peripheral, advertisementData: advertisementData)
                switch platform {
                case .android:
                    if let serviceData = advertisementData["kCBAdvDataServiceData"] as? [CBUUID: Any],
                        let rawBUID = serviceData.first?.value as? Data {
                        let raw = rawBUID.hexEncodedString()
                        device.backendIdentifier = raw
                        retryBUID.removeValue(forKey: peripheral.identifier)
                    } else {
                        log("BTScanner: No luck trying next time")
                        retryBUID[peripheral.identifier] = Date().timeIntervalSince1970
                    }
                case .iOS:
                    retryBUID.removeValue(forKey: peripheral.identifier)
                    centralManager.connect(peripheral, options: nil)
                }
                device.platform = platform
            }

            discoveredDevices[index] = device

            invoke(invocation: { $0.didUpdate(device: device) })

            return
        }

        if filterRSSIPower {
            guard allowedRSSIRange.contains(RSSI.intValue) else {
                log("BTScanner: Discovered \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")
                log("BTScanner: RSSI range \(RSSI.intValue)")
                return
            }
        }

        let device: BTDevice
        let platform = checkDeviceType(peripheral: peripheral, advertisementData: advertisementData)

        switch platform {
        case .android:
            // get BUID for android if not, we try to look as andorid
            // probably android
            var BUID: String?
            var replaceDevice: BTDevice?

            // find buid in service data
            if let serviceData = advertisementData["kCBAdvDataServiceData"] as? [CBUUID: Any],
                let rawBUID = serviceData.first?.value as? Data {
                let raw = rawBUID.hexEncodedString()

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
                log("BTScanner: Ignored device wihtout name and buid: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")
                return
            }

            device = BTDevice(
                id: replaceDevice?.id ?? UUID(),
                bluetoothIdentifier: peripheral.identifier,
                backendIdentifier: BUID,
                platform: platform,
                date: Date(),
                name: peripheral.name ?? replaceDevice?.name,
                rssi: RSSI.intValue
            )

            if replaceDevice != nil {
                discoveredDevices.append(device)
                invoke() { $0.didUpdate(device: device) }
                return
            }
        case .iOS:
            // probably iOS
            device = BTDevice(
                id: UUID(),
                bluetoothIdentifier: peripheral.identifier,
                backendIdentifier: nil,
                platform: platform,
                date: Date(),
                name: peripheral.name,
                rssi: RSSI.intValue
            )

            discoveredData[peripheral.identifier] = Data()
        }

        log("BTScanner: Discovered \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")
        discoveredPeripherals[peripheral.identifier] = peripheral

        log("BTScanner: Found \(device.platform) device \(device)")
        invoke() { $0.didFind(device: device) }
        discoveredDevices.append(device)

        if device.platform == .iOS, device.backendIdentifier == nil {
            log("BTScanner: Connecting to peripheral \(peripheral)")
            centralManager.connect(peripheral, options: nil)
        } else if device.platform == .android, device.backendIdentifier == nil {
            // try retry for android device
            log("BTScanner: Retry to get BUID for android peripheral \(peripheral)")
            retryBUID[peripheral.identifier] = Date().timeIntervalSince1970
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
            cleanup(peripheral)
            return
        }

        // Discover the characteristic we want...
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let services = peripheral.services, !services.isEmpty else {
            retryBUID[peripheral.identifier] = Date().timeIntervalSince1970
            cleanup(peripheral)
            log("BTScanner: No services to discover, will try retry in \(fetchBUIDRetry)")
            return
        }

        services.forEach {
            peripheral.discoverCharacteristics([BT.transferCharacteristic.cbUUID], for: $0) // transferCharacteristic
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            log("BTScanner: Error discovering characteristics \(String(describing: error?.localizedDescription))")
            cleanup(peripheral)
            return
        }

        guard let characteristics = service.characteristics else {
            log("BTScanner: No characteristics to subscribe")
            return
        }

        for characteristic in characteristics where acceptUUIDs.contains(characteristic.uuid) {
            log("BTScanner: ReadValue for \(characteristic.uuid)")
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

        let stringFromData = newData.hexEncodedString()
        log("BTScanner: Received: \(peripheral.identifier.uuidString) \(stringFromData)")

        // set guid
        if let index = discoveredDevices.firstIndex(where: { $0.bluetoothIdentifier == peripheral.identifier }) {
            let oldDevice = discoveredDevices[index]
            let device = BTDevice(
                id: oldDevice.id,
                bluetoothIdentifier: peripheral.identifier,
                backendIdentifier: stringFromData,
                platform: .iOS,
                date: Date(),
                name: peripheral.name ?? oldDevice.name,
                rssi: oldDevice.rssi
            )

            discoveredDevices[index] = device
            invoke() { $0.didUpdate(device: device) }
        } else {
            log("BTScanner: Error, didn't found but received!")
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
