//
//  ViewController.swift
//  btraced
//
//  Created by Tomas Svoboda on 16/03/2020.
//  Copyright © 2020 hatchery41. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Properties

    var advertiser: BTAdvertising?
    
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    private var data: Data?
    private var logText: String = "" {
        didSet {
            textView.text = logText
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        Log.delegate = self

        textView.text = ""

        if advertiser?.isRunning != true {
            advertiser = BTAdvertiser()
            advertiser?.start()
        }

        centralManager = CBCentralManager(delegate: self, queue: nil)
        if CBCentralManager.authorization != CBManagerAuthorization.allowedAlways {
            logToView("Requesting Bluetooth authorization")
        } else {
            scan()
        }
    }
    
    // MARK: - Scan
    
    private func scan() {
        centralManager.scanForPeripherals(withServices: [CB.transferService.cbUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        logToView("Scanning started")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        discoveredPeripheral = nil
        logToView("Peripheral disconnected")
        // We're disconnected, so start scanning again
        scan()
    }
    
    // MARK: - Central manager delegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        scan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        logToView("Discovered \(String(describing: peripheral.name)) \(advertisementData) at \(RSSI)")
        guard RSSI.intValue > -15 else {
            logToView("RSSI range \(RSSI.intValue)")
            return
        }
        guard RSSI.intValue < -35 else {
            logToView("RSSI range \(RSSI.intValue)")
            return
        }
        logToView("Char \(String(describing: peripheral.services))")
        // Ok, it's in range - have we already seen it?
        if discoveredPeripheral != peripheral {
            // Save it
            discoveredPeripheral = peripheral
            // And connect
            logToView("Connecting to peripheral \(peripheral)")
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logToView("Failed to connect to \(peripheral), \(String(describing: error?.localizedDescription))")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logToView("Peripheral connected")
        // Stop scanning
        centralManager.stopScan()
        logToView("Scanning stopped")
        // Clear
        data = nil
        // Discovery callbacks
        peripheral.delegate = self
        // Search only for services that match our UUID
        peripheral.discoverServices([CB.transferService.cbUUID])
    }
    
    // MARK: - Peripheral manager delegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            logToView("Error discovering services: \(String(describing: error?.localizedDescription))")
            cleanup()
            return
        }
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let services = peripheral.services else {
            logToView("No services to discover")
            return
        }
        for service in services {
            peripheral.discoverCharacteristics([CB.transferCharacteristic.cbUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            logToView("Error discovering characteristics \(String(describing: error?.localizedDescription))")
            cleanup()
            return
        }
        guard let characteristics = service.characteristics else {
            logToView("No characteristics to subscribe")
            return
        }
        for characteristic in characteristics where characteristic.uuid == CB.transferCharacteristic.cbUUID {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            logToView("Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        guard let charData = characteristic.value else {
            logToView("No data in characteristic")
            return
        }
        let stringFromData = String(data: charData, encoding: .utf8)
        if stringFromData == "EOM" {
            guard let someData = self.data else {
                logToView("No data to process")
                return
            }
            textView.text = String(data: someData, encoding: .utf8)
            peripheral.setNotifyValue(false, for: characteristic)
            centralManager.cancelPeripheralConnection(peripheral)
        }
        data?.append(charData)
        logToView("Received: \(String(describing: stringFromData))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            logToView("Error changing notification state: \(String(describing: error?.localizedDescription))")
            return
        }
        guard characteristic.uuid == CB.transferCharacteristic.cbUUID else {
            return
        }
        if characteristic.isNotifying {
            logToView("Notification began on \(characteristic)")
        } else {
            logToView("Notification stoppped on \(characteristic). Disconnecting")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: - Cleanup
    
    private func cleanup() {
        // Don't do anything if we're not connected
        guard discoveredPeripheral?.state == .connected else {
            return
        }
        // See if we are subscribed to a characteristic on the peripheral
        guard let services = discoveredPeripheral?.services else { return }
        for service in services where service.characteristics != nil {
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics where characteristic.uuid == CB.transferCharacteristic.cbUUID {
                guard !characteristic.isNotifying else { return }
                discoveredPeripheral?.setNotifyValue(false, for: characteristic)
            }
        }
    }
    
    // MARK: - Log
}

extension ViewController: LogDelegate {
    func didLog(_ text: String) {
        logToView(text)
    }
}

private extension ViewController {
    static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()

    private func logToView(_ text: String) {
        logText += "\n" + Self.formatter.string(from: Date()) + " " + text
    }
}
