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
    private var timer: Timer!

    private var data: Data?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTimer()
    }
    
    // MARK: - Setup
    
    private func setup() {
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
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            self?.textView.text = FileLogger.shared.getLog()
        }
    }
    
    // MARK: - Purge logs

    @IBAction func purgeLogs(_ sender: Any) {
        FileLogger.shared.purgeLogs()
    }
}
