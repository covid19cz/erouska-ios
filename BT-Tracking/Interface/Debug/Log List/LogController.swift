//
//  LogController.swift
//  btraced
//
//  Created by Tomas Svoboda on 16/03/2020.
//  Copyright © 2020 hatchery41. All rights reserved.
//

import UIKit
import CoreBluetooth

class LogController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Properties

    private var advertiser: BTAdvertising = AppDelegate.shared.advertiser
    private var scanner: BTScannering = AppDelegate.shared.scanner

    private var logText: String = "" {
        didSet {
            textView.text = logText
        }
    }

    // MARK: - Lifecycle

    deinit {
        scanner.remove(delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        Log.delegate = self

        textView.text = ""

        scanner.add(delegate: self)
    }

    // MARK: -

    func purgeLog() {
        logText = ""
    }

}

extension LogController: BTScannerDelegate {
    func didFind(device: BTScanUpdate) {
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

    func didUpdate(device: BTScanUpdate) {
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

extension LogController: LogDelegate {
    func didLog(_ text: String) {
        logToView(text)
    }
}

private extension LogController {
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
