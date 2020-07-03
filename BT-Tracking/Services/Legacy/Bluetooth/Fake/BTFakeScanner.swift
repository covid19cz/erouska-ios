//
//  BTFakeScanner.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 21/05/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTFakeScanner: BTScannering {

    var deviceUpdateLimit: TimeInterval = 0

    var filterRSSIPower: Bool = false

    var fetchBUIDRetry: TimeInterval = 0

    var removeDevicesAfterAreMissingForTime: TimeInterval = 0

    var state: CBManagerState = .poweredOn

    var didUpdateState: UpdateState?

    var isRunning: Bool = false

    private(set) var exposure: ExposureServicing

    init() {
        exposure = ExposureService()

        log("Exposure: \(String(describing: exposure.isEnabled))")
        log("Exposure: \(String(describing: exposure.isActive))")
        log("Exposure: \(String(describing: exposure.status.rawValue))")

        if exposure.isEnabled, exposure.isActive {
            isRunning = true
        }

    }

    func add(delegate: BTScannerDelegate) {

    }

    func remove(delegate: BTScannerDelegate) {

    }

    func start() {
        exposure.activate(callback: { error in
            if let error = error {
                log("Exposure error: \(error)")
            } else {
                self.isRunning = true
                log("Exposure is active!")
            }
        })

        if exposure.isEnabled, exposure.isActive {
            isRunning = true
        }
    }

    func stop() {
        exposure.deactivate { error in
            if let error = error {
                log("Exposure error: \(error)")
            } else {
                self.isRunning = false
                log("Exposure is deactivated!")
            }
        }
        exposure = ExposureService()
    }

}
