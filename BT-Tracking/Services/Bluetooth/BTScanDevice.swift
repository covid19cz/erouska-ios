//
//  BTDevice.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 09/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BTPlatform: String {
    case iOS, android = "Android"
}

class BTScanDevice {

    /// Missing RSII device RSII value
    static var DisconnectedRSII = -200

    /// Number of updateds from device, before it will try to connect and get BUID
    static var NumberOfUpdatesNeededForConnection = 3

    static var DeviceIsMissingAfterSeconds = 2 * 60

    static var RetryTimeInSeconds: TimeInterval = 60

    static var MaxNumberOfRetries = 3

    // MARK: -
    
    let id: UUID

    enum State {
        /// intial
        case intial
        /// before disovered backend identifier
        case noBackendIdentifier
        /// is conncting to bt device
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

    private(set) var state: State = .intial

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
        case .noBackendIdentifier, .idle:
            return numberOfUpdates >= Self.NumberOfUpdatesNeededForConnection
        case .waitingForRetry:
            let retryTimeInterval = (lastConnectionDate?.timeIntervalSinceReferenceDate ?? 0) + Self.RetryTimeInSeconds
            return retryTimeInterval < Date.timeIntervalSinceReferenceDate && connectionRetries < Self.MaxNumberOfRetries
        default:
            return false
        }
    }

    private(set) var platform: BTPlatform?

    init(peripheral: CBPeripheral, RSII: Int, advertisementData: [String: Any]) {
        self.id = UUID()
        self.peripheral = peripheral
        self.firstDiscoveryDate = Date()

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

    func didStartConnection() {
        lastConnectionDate = Date()
    }

    func didConnect(_ peripheral: CBPeripheral) {

    }

    func didFailToConnect(error: Error?) {
        state = .waitingForRetry
        connectionRetries += 1
        lastError = error
    }

    func cleanupConnection(_ selectedPeripheral: CBPeripheral? = nil) {
        let peripheral = selectedPeripheral ?? lastPeripheral ?? self.peripheral

        // Don't do anything if we're not connected
        // See if we are subscribed to a characteristic on the peripheral
        guard peripheral.state == .connected, let services = peripheral.services else { return }

        for service in services where service.characteristics != nil {
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics where [BT.broadcastCharacteristic.cbUUID].contains(characteristic.uuid) {
                guard !characteristic.isNotifying else { return }
                peripheral.setNotifyValue(false, for: characteristic)
            }
        }
    }

}

extension BTScanDevice: Equatable {

    static func == (lhs: BTScanDevice, rhs: BTScanDevice) -> Bool {
        return lhs.id == rhs.id
    }

}

private extension BTScanDevice {

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
