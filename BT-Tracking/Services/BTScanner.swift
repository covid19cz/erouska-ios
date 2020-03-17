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
    func didFound(device: CBPeripheral)
    func didReadData(for device: CBPeripheral, data: Data)
}

final class BTScanner: NSObject, BTScannering, CBCentralManagerDelegate, CBPeripheralDelegate {

    private var centralManager: CBCentralManager! = nil
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    private var discoveredData: [UUID: Data] = [:]

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
                CBCentralManagerScanOptionAllowDuplicatesKey: false
            ]
        )
        log("BTScanner: Scanning started")
    }

    func stop() {
        started = false
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
            log("BTScanner: Update \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")
            return
        }
        log("BTScanner: Discovered \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")
        discoveredPeripherals[peripheral.identifier] = peripheral
        discoveredData[peripheral.identifier] = Data()

        guard RSSI.intValue > -15 else {
            log("BTScanner: RSSI range \(RSSI.intValue)")
            return
        }
        guard RSSI.intValue < -35 else {
            log("BTScanner: RSSI range \(RSSI.intValue)")
            return
        }
        log("BTScanner: Char \(String(describing: peripheral.services))")

        log("BTScanner: Connecting to peripheral \(peripheral)")
        centralManager.connect(peripheral, options: nil)
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
        peripheral.discoverServices([BT.broadcastCharacteristic.cbUUID])
        // [BT.transferService.cbUUID, BT.broadcastCharacteristic.cbUUID]
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log("BTScanner: didDisconnectPeripheral: \(peripheral), error: \(error?.localizedDescription ?? "none")")

        cleanup(peripheral)
        discoveredPeripherals.removeValue(forKey: peripheral.identifier)
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
        guard let services = peripheral.services else {
            log("BTScanner: No services to discover")
            return
        }

        for service in services {
            peripheral.discoverCharacteristics([BT.transferCharacteristic.cbUUID], for: service)
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
        for characteristic in characteristics where characteristic.uuid == BT.transferCharacteristic.cbUUID {
            peripheral.setNotifyValue(true, for: characteristic)
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

        let stringFromData = String(data: newData, encoding: .utf8)
        if stringFromData == "EOM" { // TODO
            guard let resultData = discoveredData[peripheral.identifier] else {
                log("BTScanner: No data to process")
                return
            }

            delegate?.didReadData(for: peripheral, data: resultData)

            peripheral.setNotifyValue(false, for: characteristic)
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        discoveredData[peripheral.identifier]?.append(newData)
        log("Received: \(String(describing: stringFromData))")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            log("BTScanner: Error changing notification state: \(String(describing: error?.localizedDescription))")
            return
        }

        guard characteristic.uuid == BT.transferCharacteristic.cbUUID else {
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
            for characteristic in characteristics where characteristic.uuid == BT.transferCharacteristic.cbUUID {
                guard !characteristic.isNotifying else { return }
                peripheral.setNotifyValue(false, for: characteristic)
            }
        }
    }

}
