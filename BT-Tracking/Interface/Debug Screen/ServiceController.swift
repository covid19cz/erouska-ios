//
//  ServiceController.swift
//  btraced
//
//  Created by Tomas Svoboda on 16/03/2020.
//  Copyright © 2020 hatchery41. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Properties

    private var advertiser: BTAdvertising?
    private var scanner: BTScannering?

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
        if scanner?.isRunning != true {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            scanner = appDelegate.scanner
            scanner?.delegate = self
        }
    }

    // MARK: -

    func purgeLog() {
        logText = ""
    }

}

extension ServiceController: BTScannerDelegate {
    func didFound(device: CBPeripheral, RSSI: Int) {
        let text = "Found device: \(device.identifier.uuidString), signal: \(RSSI)"

        let content = UNMutableNotificationContent()
        content.title = "Found device: \(device.identifier.uuidString)"
        content.body = "Signal: \(RSSI)"

        localLog(text, notification: content)
    }

    func didUpdate(device: CBPeripheral, RSSI: Int) {
        let text = "Updated device: \(device.identifier.uuidString), signal: \(RSSI)"
        localLog(text)
    }

    func didReadData(for device: CBPeripheral, data: Data) {
        let string = String(data: data, encoding: .utf8)
        let text = "Read data: \(device.identifier.uuidString), \(string ?? "failed to decode")"

        let content = UNMutableNotificationContent()
        content.title = "Read data"
        content.body = string ?? ""

        localLog(text, notification: content)
    }

    private func localLog(_ text: String, notification: UNMutableNotificationContent? = nil) {
        log("\n" + text + "\n")
        logToView(text)

        guard AppDelegate.inBackground, let notification = notification else { return }
        notification.sound = .none

        let request = UNNotificationRequest(identifier: "Scanning",  content: notification, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

    }
}

extension ServiceController: LogDelegate {
    func didLog(_ text: String) {
        //logToView(text)
    }
}

private extension ServiceController {
    static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()

    private func logToView(_ text: String) {
        logText += "\n" + Self.formatter.string(from: Date()) + " " + text
    }
}
