//
//  ViewController.swift
//  btraced
//
//  Created by Tomas Svoboda on 16/03/2020.
//  Copyright © 2020 hatchery41. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Properties

    private var advertiser: BTAdvertising?
    private var scanner: BTScannering?


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

        if scanner?.isRunning != true {
            scanner = BTScanner()
            scanner?.delegate = self
            scanner?.start()
        }
    }

}

extension ViewController: BTScannerDelegate {

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
