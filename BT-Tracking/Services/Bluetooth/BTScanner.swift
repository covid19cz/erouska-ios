//
//  BTScanner.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift

protocol BTScannering: class {

    /// default: 3, in seconds
    var deviceUpdateLimit: TimeInterval { get set }
    /// default: -90...0, in RSSI
    var filterRSSIPower: Bool { get set }
    /// default: 60, in seconds
    var fetchBUIDRetry: TimeInterval { get set }
    /// default: 3 min, in seocnds
    var removeDevicesAfterAreMissingForTime: TimeInterval { get set }

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
    func didFind(device: BTScanUpdate)
    func didUpdate(device: BTScanUpdate)
}

final class BTScanner: MulticastDelegate<BTScannerDelegate>, BTScannering, CBCentralManagerDelegate, CBPeripheralDelegate {

    private let bag = DisposeBag()

    private var centralManager: CBCentralManager! = nil

    private var discoveredDevices: [UUID: BTScanDevice] = [:]

    private var deviceRemoverTimer: Observable<Int>

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

        deviceRemoverTimer = Observable.timer(
            .seconds(0),
            period: .seconds(Int(removeDevicesAfterAreMissingForTime)),
            scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
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

    var removeDevicesAfterAreMissingForTime: TimeInterval = 3 * 60

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

        discoveredDevices.removeAll()

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

    private func checkRefreshTime(device: BTScanDevice) -> Bool {
        guard let timeInterval = device.lastConnectionDate?.timeIntervalSinceReferenceDate else { return false }
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

    func checkDeviceType(peripheral: CBPeripheral, advertisementData: [String : Any]) -> BTScanUpdate.Platform {
        return advertisementData["kCBAdvDataServiceData"] == nil ? .iOS : .android
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if filterRSSIPower {
            guard allowedRSSIRange.contains(RSSI.intValue) else {
                log("BTScanner: Discovered \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")
                log("BTScanner: RSSI range \(RSSI.intValue)")
                return
            }
        }

        guard let device = discoveredDevices[peripheral.identifier] else {
            log("BTScanner: Discovered \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")

            let newDevice = BTScanDevice(peripheral: peripheral, RSII: RSSI.intValue, advertisementData: advertisementData)
            discoveredDevices[peripheral.identifier] = newDevice

            log("BTScanner: Found \(String(describing: newDevice.platform)) device \(newDevice)")
            invoke() { $0.didFind(device: newDevice.toScanUpdate()) }
            return
        }

        device.update(with: peripheral, RSII: RSSI.intValue, advertisementData: advertisementData)

        // limit rssi updates
        if checkRefreshTime(device: device) {
            log("BTScanner: Update ID: \(peripheral.identifier.uuidString) at \(RSSI)")
            invoke() { $0.didUpdate(device: device.toScanUpdate()) }
        }

        if device.isReadyToConnect {
            device.didStartConnection()
            central.connect(peripheral, options: nil)
        }

        if device.backendIdentifier != nil, let otherDevice = discoveredDevices.first(where: { $0.value.backendIdentifier == device.backendIdentifier })?.value,
        device != otherDevice {
            otherDevice.mergeWith(scan: device)
            discoveredDevices[peripheral.identifier] = otherDevice
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log("BTScanner: Failed to connect to \(peripheral), error: \(error?.localizedDescription ?? "none")")

        // report missing device?
        guard let device = discoveredDevices[peripheral.identifier] else { return }
        device.didFailToConnect(error: error)
        device.cleanupConnection(peripheral)
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

        if error != nil {
            retryBUID[peripheral.identifier] = Date().timeIntervalSince1970
            cleanup(peripheral)
            log("BTScanner: Disconnect with error, will try retry in \(fetchBUIDRetry)")
            return
        }
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
            let device = BTScanUpdate(
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
        discoveredDevices.forEach {
            $0.value.cleanupConnection()
        }
    }

}
