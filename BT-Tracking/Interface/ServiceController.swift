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
            scanner = BTScanner()
            scanner?.start()
        }
    }

    // MARK: -

    func purgeLog() {
        logText = ""
    }

}

extension ServiceController: BTScannerDelegate {
    func didFound(device: CBPeripheral) {
        logToView("Found device: \(device.identifier.uuidString)")
    }

    func didReadData(for device: CBPeripheral, data: Data) {
        let string = String(data: data, encoding: .utf8)
        logToView("Read data: \(device.identifier.uuidString), \(string ?? "failed to decode")")
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
