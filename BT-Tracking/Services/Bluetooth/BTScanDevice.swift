//
//  BTDevice.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 09/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift

enum BTPlatform: String {
    case unknown = "Unknown", iOS, android = "Android"
}

class BTScanDevice: NSObject {

    /// Missing RSII device RSII value
    static let DisconnectedRSII = -200

    /// Number of updateds from device, before it will try to connect and get BUID
    static let NumberOfUpdatesNeededForConnection = 3

    static let DeviceIsMissingAfterSeconds = 2 * 60

    static let RetryTimeInSeconds: TimeInterval = 60

    static let MaxNumberOfRetries = 3

    static let AcceptedUUIDs = [BT.transferCharacteristic.cbUUID]

    // MARK: -
    
    let id: UUID

    enum State {
        /// intial
        case intial
        /// connecting to peripheral
        case conntecting
        /// is conected to bt device
        case connected
        /// disconncted - failed to connect to bt device
        case disconnected
        /// scanner is waiting for bt device connection retry
        case waitingForRetry
        /// idle, updating rsii
        case idle
        /// not updates from bt in x seconds
        case missing
    }

    private(set) var state: State = .intial {
        didSet {
            observableState.onNext(state)
        }
    }
    var observableState: BehaviorSubject<State> = BehaviorSubject(value: .intial)

    let manager: CBCentralManager
    let peripheral: CBPeripheral

    private(set) var backendIdentifier: String? // buids

    private(set) var firstDiscoveryDate: Date?

    private(set) var lastPeripheral: CBPeripheral?

    private(set) var lastDiscoveryDate: Date?

    private(set) var connectionRetries: Int = 0

    private(set) var lastConnectionDate: Date?

    private(set) var lastError: Error?

    var RSII: Int {
        return RSIIs.last ?? Self.DisconnectedRSII
    }
    var medianRSII: Int? {
        if let value = RSIIs.median() {
            return Int(value)
        }
        return nil
    }
    private var RSIIs: [Int] = []

    private var numberOfUpdates: Int = 0

    var isReadyToConnect: Bool {
        switch state {
        case .intial, .idle:
            return numberOfUpdates >= Self.NumberOfUpdatesNeededForConnection
        case .waitingForRetry:
            let retryTimeInterval = (lastConnectionDate?.timeIntervalSinceReferenceDate ?? 0) + Self.RetryTimeInSeconds
            return retryTimeInterval < Date.timeIntervalSinceReferenceDate && connectionRetries < Self.MaxNumberOfRetries
        default:
            return false
        }
    }

    private(set) var platform: BTPlatform = .unknown

    init(manager: CBCentralManager, peripheral: CBPeripheral, RSII: Int, advertisementData: [String: Any]) {
        self.id = UUID()
        self.manager = manager
        self.peripheral = peripheral
        self.firstDiscoveryDate = Date()
        super.init()

        update(with: peripheral, RSII: RSII, advertisementData: advertisementData)
    }

    /// Called usually from central:didDiscover:peripheral:advertisementData:
    func update(with peripheral: CBPeripheral, RSII: Int, advertisementData: [String: Any]) {
        lastPeripheral = peripheral
        lastDiscoveryDate = Date()
        numberOfUpdates += 1

        RSIIs.append(RSII)

        guard backendIdentifier == nil else { return }

        if tryToFetchBackendIdentifier(advertisementData: advertisementData) {
            state = .idle
        }
    }

    /// Some device (mostly android) are chaning rapidly bluetooth identifiers, so we need to make one record and update btid
    func mergeWith(scan: BTScanDevice) {
        guard backendIdentifier == scan.backendIdentifier else { return }

        lastPeripheral = scan.lastPeripheral
        lastDiscoveryDate = scan.lastDiscoveryDate
        numberOfUpdates += scan.numberOfUpdates

        RSIIs.append(contentsOf: scan.RSIIs)
    }

    func connect(to peripheral: CBPeripheral) {
        state = .conntecting
        manager.connect(peripheral, options: nil)
    }

    func discoverServices(from peripheral: CBPeripheral) {
        state = .connected
        lastConnectionDate = Date()

        peripheral.delegate = self
        peripheral.discoverServices(Self.AcceptedUUIDs)
    }

    func didFail(to peripheral: CBPeripheral, error: Error?) {
        cleanupConnection(peripheral)
        lastError = error

        guard connectionRetries < Self.MaxNumberOfRetries else {
            state = .disconnected
            return
        }
        state = .waitingForRetry
        connectionRetries += 1
    }

    func didDisconnect(peripheral: CBPeripheral, error: Error?) {
        guard error == nil else {
            didFail(to: peripheral, error: error)
            log("BTScanner: Disconnect with error, will try retry in \(Self.RetryTimeInSeconds)")
            return
        }

        if [State.idle, .disconnected, .waitingForRetry].contains(state) {
            return
        }
        didFail(to: peripheral, error: nil)
    }

    func toScanUpdate() -> BTScanUpdate {
        return BTScanUpdate(
            id: id,
            bluetoothIdentifier: peripheral.identifier,
            backendIdentifier: backendIdentifier,
            platform: platform == .iOS ? .iOS : .android,
            date: lastDiscoveryDate ?? firstDiscoveryDate ?? Date(),
            name: nil,
            rssi: RSII,
            medianRssi: medianRSII
        )
    }

    // MARK: - Connection updates

    func cleanupConnection(_ selectedPeripheral: CBPeripheral? = nil) {
        let peripheral = selectedPeripheral ?? lastPeripheral ?? self.peripheral

        // Don't do anything if we're not connected
        // See if we are subscribed to a characteristic on the peripheral
        guard peripheral.state == .connected, let services = peripheral.services else { return }

        for service in services where service.characteristics != nil {
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics where Self.AcceptedUUIDs.contains(characteristic.uuid) {
                guard !characteristic.isNotifying else { return }
                peripheral.setNotifyValue(false, for: characteristic)
            }
        }
        manager.cancelPeripheralConnection(peripheral)
    }

    // MARK: - Equatable

    override func isEqual(_ object: Any?) -> Bool {
        return self.id == (object as? BTScanUpdate)?.id
    }

    static func == (lhs: BTScanDevice, rhs: BTScanDevice) -> Bool {
        return lhs.id == rhs.id
    }

}

extension BTScanDevice: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            didFail(to: peripheral, error: error)
            log("BTScanner: Error discovering services: \(String(describing: error?.localizedDescription))")
            return
        }
        didDiscoverServices(to: peripheral)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            didFail(to: peripheral, error: error)
            log("BTScanner: Error discovering characteristics \(String(describing: error?.localizedDescription))")
            return
        }
        didDiscoverCharacteristics(for: peripheral, service: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            didFail(to: peripheral, error: error)
            log("BTScanner: Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        didReadValue(from: peripheral, characteristic: characteristic)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            didFail(to: peripheral, error: error)
            log("BTScanner: Error changing notification state: \(String(describing: error?.localizedDescription))")
            return
        }

        guard Self.AcceptedUUIDs.contains(characteristic.uuid) else {
            didFail(to: peripheral, error: nil)
            log("BTScanner: Error not accepted characteristic: \(characteristic)")
            return
        }

        if characteristic.isNotifying {
            log("BTScanner: Notification began on \(characteristic)")
        } else {
            cleanupConnection(peripheral)
            log("BTScanner: Notification stoppped on \(characteristic). Disconnecting")
        }
    }

}

private extension BTScanDevice {

    func didDiscoverServices(to peripheral: CBPeripheral) {
        state = .connected
        lastConnectionDate = Date()

        // Discover the characteristic we want...
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let services = peripheral.services, !services.isEmpty else {
            didFail(to: peripheral, error: nil)
            log("BTScanner: No services to discover, will try retry in \(Self.RetryTimeInSeconds)s")
            return
        }

        services.forEach {
            peripheral.discoverCharacteristics(Self.AcceptedUUIDs, for: $0)
        }
    }

    func didDiscoverCharacteristics(for peripheral: CBPeripheral, service: CBService) {
        guard let characteristics = service.characteristics else {
            didFail(to: peripheral, error: nil)
            log("BTScanner: No characteristics to subscribe")
            return
        }

        var foundCharacteristic: Bool = false
        for characteristic in characteristics where Self.AcceptedUUIDs.contains(characteristic.uuid) {
            log("BTScanner: ReadValue for \(characteristic.uuid)")
            peripheral.readValue(for: characteristic)
            foundCharacteristic = true
        }

        if !foundCharacteristic {
            didFail(to: peripheral, error: nil)
        }
    }

    func didReadValue(from peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard let newData = characteristic.value else {
            didFail(to: peripheral, error: nil)
            log("BTScanner: No data in characteristic")
            return
        }

        peripheral.setNotifyValue(false, for: characteristic)
        manager.cancelPeripheralConnection(peripheral)
        cleanupConnection(peripheral)

        let stringFromData = newData.hexEncodedString()
        log("BTScanner: Received: \(peripheral.identifier.uuidString) \(stringFromData)")

        backendIdentifier = stringFromData
        platform = .iOS
        connectionRetries = 0
        state = .idle
    }

    func tryToFetchBackendIdentifier(advertisementData: [String: Any]) -> Bool {
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Any],
            let rawBUID = serviceData.first?.value as? Data {
            let raw = rawBUID.hexEncodedString()
            backendIdentifier = raw
            platform = .android
            return true
        }
        return false
    }

}
