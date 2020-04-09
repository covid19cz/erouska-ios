//
//  BTAdvertiser.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift

protocol BTAdvertising: class {

    init(TUIDs: [String], IDRotation: Int)

    @available(iOS 13.0, *)
    var authorization: CBManagerAuthorization { get }

    var currentID: String? { get }
    typealias IDChangeCallback = () -> Void
    var didChangeID: IDChangeCallback? { get set }

    var isRunning: Bool { get }
    func start()
    func stop()
    
}

final class BTAdvertiser: NSObject, BTAdvertising, CBPeripheralManagerDelegate {

    private let bag = DisposeBag()

    // Advertising ID
    private let TUIDs: [String]
    private(set) var currentID: String?
    var didChangeID: IDChangeCallback?

    private let IDRotation: Int
    private var IDRotationTimer: Observable<Int>

    // Brodcasting
    private var peripheralManager: CBPeripheralManager! = nil

    private var serviceBroadcast: CBCharacteristic?
    private var uniqueBroadcast: CBCharacteristic?
    private var service: CBMutableService?

    @available(iOS 13.0, *)
    var authorization: CBManagerAuthorization {
        if #available(iOS 13.1, *) {
            return CBPeripheralManager.authorization
        } else {
            return peripheralManager.authorization
        }
    }

    init(TUIDs: [String], IDRotation: Int) {
        self.TUIDs = TUIDs
        self.IDRotation = IDRotation
        self.IDRotationTimer = Observable.timer(
            .seconds(0),
            period: .seconds(IDRotation),
            scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
        )

        super.init()

        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil,
            options: [
                CBPeripheralManagerOptionShowPowerAlertKey: false, // ask to turn on bluetooth
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
        return peripheralManager.isAdvertising && started
    }
    private var started: Bool = false

    func start() {
        started = true
        guard !isRunning, peripheralManager.state == .poweredOn else { return }

        peripheralManager.startAdvertising([
            // CBAdvertisementDataLocalNameKey: BT.advertiserName.rawValue, disabled for sthorter BT packet
            CBAdvertisementDataServiceUUIDsKey : [BT.transferService.cbUUID]
        ])

        IDRotationTimer
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard self?.isRunning == true else { return }
                self?.rotateDeviceID()
                self?.didChangeID?()
            })
            .disposed(by: bag)

        log("BTAdvertiser: started")
    }

    func stop() {
        started = false
        guard isRunning else { return }

        peripheralManager.stopAdvertising()

        IDRotationTimer = Observable.timer(
            .seconds(0),
            period: .seconds(IDRotation),
            scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
        )

        log("BTAdvertiser: stoped")
    }

    private func setupService() {
        pickNewDeviceID()
        let transferService = CBMutableService(type: BT.transferService.cbUUID, primary: true)
        transferService.characteristics = setupCharacteristic()
        peripheralManager.add(transferService)
        service = transferService
    }

    private func setupCharacteristic() -> [CBMutableCharacteristic] {
        let serviceBroadcast = CBMutableCharacteristic(
            type: BT.transferCharacteristic.cbUUID,
            properties: .read,
            value: currentID?.hexData, // ID device according to BE spec
            permissions: .readable
        )
        self.serviceBroadcast = serviceBroadcast

        #if DEBUG
        let uniqueBroadcast = CBMutableCharacteristic(
              type: BT.broadcastCharacteristic.cbUUID,
              properties: .read,
              value: BTDeviceName.data(using: .utf8),
              permissions: .readable
        )
        self.uniqueBroadcast = uniqueBroadcast

        return [serviceBroadcast, uniqueBroadcast]
        #else
        return [serviceBroadcast]
        #endif
    }

    private func rotateDeviceID() {
        pickNewDeviceID()
        log("BTAdvertiser: Did rotate to ID: \(currentID ?? "error")")

        guard let service = service else { return }

        DispatchQueue.main.async {
            service.characteristics = self.setupCharacteristic()
            self.peripheralManager.removeAllServices()

            self.peripheralManager.add(service)
        }
    }

    private func pickNewDeviceID() {
        guard !TUIDs.isEmpty else { return }
        let randomIndex = Int.random(in: 0..<TUIDs.count)
        let randomID = TUIDs[randomIndex]

        if currentID == nil || currentID != randomID {
            currentID = randomID
        } else {
            pickNewDeviceID()
        }
    }

    // MARK: CBPeripheralManagerDelegate

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Opt out from any other state
        if peripheral.state != .poweredOn {
            log("BTAdvertiser: peripheralManager state \(peripheral.state)")
            return
        }

        log("BTAdvertiser: peripheralManager powered on")

        setupService()

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
        log("BTAdvertiser: didReceiveRead: \(request)")

        let characteristic: CBCharacteristic

        if let uniqueBroadcast = uniqueBroadcast, request.characteristic.uuid == uniqueBroadcast.uuid {
            characteristic = uniqueBroadcast
        } else if let serviceBroadcast = serviceBroadcast, request.characteristic.uuid == serviceBroadcast.uuid {
            characteristic = serviceBroadcast
        } else {
            peripheralManager.respond(to: request, withResult: .attributeNotFound)
            return
        }

        guard let value = characteristic.value, request.offset <= value.count else {
            peripheralManager.respond(to: request, withResult: .invalidOffset)
            return
        }

        let range = request.offset...(value.count - request.offset)
        request.value = characteristic.value?.subdata(in: range.lowerBound..<range.upperBound)
        peripheral.respond(to: request, withResult: .success)
    }

}
