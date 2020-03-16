//
//  BTAdvertiser.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BTAdvertising: class {

    var isRunning: Bool { get }
    func start()
    func stop()
    
}

final class BTAdvertiser: NSObject, BTAdvertising, CBPeripheralManagerDelegate {

    private var peripheralManager: CBPeripheralManager! = nil

    override init() {
        super.init()

        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil,
            options: [
                // CBPeripheralManagerOptionShowPowerAlertKey: ?
                CBPeripheralManagerOptionRestoreIdentifierKey: true
            ]
        )

        if #available(iOS 13.1, *) {
            if ![CBManagerAuthorization.allowedAlways, .restricted].contains(CBPeripheralManager.authorization) {
                log("BTAdvertiser: Not authorized! \(CBPeripheralManager.authorization)")
                return
            }
        } else if #available(iOS 13.0, *) {
            if ![CBManagerAuthorization.allowedAlways, .restricted].contains(peripheralManager.authorization) {
                log("BTAdvertiser: Not authorized! \(peripheralManager.authorization)")
                return
            }
        }
    }

    // MARK: - BTAdvertising

    var isRunning: Bool {
        return peripheralManager.isAdvertising
    }
    private var started: Bool = false

    func start() {
        started = true
        guard !isRunning, peripheralManager.state == .poweredOn else { return }

        peripheralManager.startAdvertising([
            //CBAdvertisementDataIsConnectable: true, // TODO: off, currently conenction is not implemented
            CBAdvertisementDataLocalNameKey: BT.advertiserName.rawValue,
            CBAdvertisementDataServiceUUIDsKey : [BT.transferService.cbUUID]
        ])

        log("BTAdvertiser: started")
    }

    func stop() {
        started = false
        guard isRunning else { return }

        peripheralManager.stopAdvertising()

        log("BTAdvertiser: stoped")
    }

    // MARK: CBPeripheralManagerDelegate

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Opt out from any other state
        if peripheral.state != .poweredOn {
            log("BTAdvertiser: peripheralManager state \(peripheral.state)")
            return
        }

        log("BTAdvertiser: peripheralManager powered on")

        let serviceBroadcast = CBMutableCharacteristic(
            type: BT.transferCharacteristic.cbUUID,
            properties: .read,
            value: "test serviceBroadcast".data(using: .utf8),
            permissions: .readable)

        let uniqueBroadcast = CBMutableCharacteristic(
              type: BT.broadcastCharacteristic.cbUUID,
              properties: .read,
              value: "test service phone".data(using: .utf8),
              permissions: .readable)


        let transferService = CBMutableService(type: BT.transferService.cbUUID, primary: true)
        transferService.characteristics = [serviceBroadcast, uniqueBroadcast]

        peripheralManager.add(transferService)

        guard started else { return }
        start()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        log("BTAdvertiser: willRestoreState, dict: \(dict)")
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        log("BTAdvertiser: peripheralManagerDidStartAdvertising, error: \(error?.localizedDescription ?? "none")")
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        log("BTAdvertiser: peripheralManagerIsReady")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        log("BTAdvertiser: subscribed to characteristic \(characteristic)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        log("BTAdvertiser: unsubscribed to characteristic \(characteristic)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        log("BTAdvertiser: didAddService: \(service), error: \(error?.localizedDescription ?? "none")")
    }


    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        log("BTAdvertiser: peripheralManagerDidStartAdvertising, didReceiveRead: \(request)")
    }

}
