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
    func didFind(device: BTScan)
    func didUpdate(device: BTScan)
}

final class BTScanner: MulticastDelegate<BTScannerDelegate>, BTScannering {

    private let bag = DisposeBag()

    private var centralManager: CBCentralManager! = nil

    private var discoveredDevices: [UUID: BTScanDevice] = [:]

    private var deviceRemoverTimer: Observable<Int>

    private let acceptUUIDs = [BT.broadcastCharacteristic.cbUUID, BT.transferCharacteristic.cbUUID]

    override init() {
        deviceRemoverTimer = Observable.timer(
            .seconds(0),
            period: .seconds(Int(removeDevicesAfterAreMissingForTime)),
            scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
        )

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

    var removeDevicesAfterAreMissingForTime: TimeInterval = 3 * 60

    var isRunning: Bool {
        return centralManager.isScanning
    }
    private var started: Bool = false

    var state: CBManagerState {
        return centralManager.state
    }
    var didUpdateState: UpdateState?

    deinit {
        cleanup()
    }

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

        cleanup()
        centralManager.stopScan()
    }

}

extension BTScanner: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("BTScanner: centralManagerDidUpdateState: \(central.state.rawValue)")

        didUpdateState?(central.state)

        guard central.state == .poweredOn else { return }

        guard started else { return }
        start()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if filterRSSIPower {
            guard allowedRSSIRange.contains(RSSI.intValue) else {
                log("BTScanner: Discovered \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")
                log("BTScanner: RSSI range \(RSSI.intValue)")
                return
            }
        }

        guard var device = discoveredDevices[peripheral.identifier] else {
            log("BTScanner: Discovered \(String(describing: peripheral.name)) ID: \(peripheral.identifier.uuidString) \(advertisementData) at \(RSSI)")

            let newDevice = BTScanDevice(manager: central, peripheral: peripheral, RSII: RSSI.intValue, advertisementData: advertisementData)
            newDevice.observableState.bind { [weak self] state in
                newDevice.lastUpdateInvokeDate? = Date()
                self?.invoke() { $0.didUpdate(device: newDevice.toScanUpdate()) }
            }.disposed(by: bag)

            discoveredDevices[peripheral.identifier] = newDevice

            log("BTScanner: Found \(String(describing: newDevice.platform)) device \(newDevice)")
            invoke() { $0.didFind(device: newDevice.toScanUpdate()) }
            return
        }

        device.update(with: peripheral, RSII: RSSI.intValue, advertisementData: advertisementData)

        if device.isReadyToConnect, device.backendIdentifier == nil {
            device.connect(to: peripheral)
        }

        if device.backendIdentifier != nil,
            let otherDevice = discoveredDevices.first(where: { $0.value.backendIdentifier == device.backendIdentifier && $0.value != device })?.value {
            otherDevice.mergeWith(scan: device)
            discoveredDevices[peripheral.identifier] = otherDevice
            device = otherDevice
        }

        if checkRefreshTime(device: device) {
            log("BTScanner: Update ID: \(peripheral.identifier.uuidString) at \(RSSI)")

            device.lastUpdateInvokeDate? = Date()
            invoke() { $0.didUpdate(device: device.toScanUpdate()) }
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log("BTScanner: Failed to connect to \(peripheral), error: \(error?.localizedDescription ?? "none")")

        // report missing device?
        guard let device = discoveredDevices[peripheral.identifier] else { return }
        device.didFail(to: peripheral, error: error)
    }

    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        log("BTScanner: connectionEventDidOccur \(peripheral), event: \(event)")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("BTScanner: Peripheral connected \(peripheral)")

        guard let device = discoveredDevices[peripheral.identifier] else { return }
        device.discoverServices(from: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log("BTScanner: didDisconnectPeripheral: \(peripheral), error: \(error?.localizedDescription ?? "none")")

        guard let device = discoveredDevices[peripheral.identifier] else { return }
        device.didDisconnect(peripheral: peripheral, error: error)
    }

}

private extension BTScanner {

    func checkRefreshTime(device: BTScanDevice) -> Bool {
        guard let timeInterval = device.lastUpdateInvokeDate?.timeIntervalSinceReferenceDate else { return false }

        guard !AppDelegate.inBackground else {
            if !reportedBackground {
                log("Background refresh limit Disabled")
            }
            reportedBackground = true
            return true
        }
        reportedBackground = false
        return timeInterval + deviceUpdateLimit < Date.timeIntervalSinceReferenceDate
    }

    func checkDeviceType(peripheral: CBPeripheral, advertisementData: [String : Any]) -> BTPlatform {
        return advertisementData["kCBAdvDataServiceData"] == nil ? .iOS : .android
    }

    func cleanup() {
        discoveredDevices.forEach {
            $0.value.cleanupConnection()
        }
    }

}
