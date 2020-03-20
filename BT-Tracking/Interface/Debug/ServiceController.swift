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

    private var advertiser: BTAdvertising = AppDelegate.delegate.advertiser
    private var scanner: BTScannering = AppDelegate.delegate.scanner

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

        if advertiser.isRunning != true {
            advertiser.start()
        }

        if scanner.isRunning != true {
            scanner.start()
        }
        scanner.add(delegate: self)
    }

    // MARK: -

    func purgeLog() {
        logText = ""
    }

}

extension ServiceController: BTScannerDelegate {
    func didFind(device: BTDevice) {
        let text = "Found device: \(device.bluetoothIdentifier.uuidString), buid: \(device.backendIdentifier ?? "unknown"), platform: \(device.platform), signal: \(device.rssi)"

        #if DEBUG
        let content = UNMutableNotificationContent()
        content.title = "Found device: \(device.bluetoothIdentifier.uuidString)"
        content.body = "Signal: \(device.rssi), BUID: \(device.backendIdentifier ?? "unknown")"
        localLog(text, notification: content)
        #else
        localLog(text, notification: nil)
        #endif
    }

    func didUpdate(device: BTDevice) {
        let text = "Updated device: \(device.bluetoothIdentifier.uuidString), signal: \(device.rssi)"
        localLog(text)
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
        logToView(text)
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
