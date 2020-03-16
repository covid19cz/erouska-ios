//
//  BTScanner.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

protocol BTScannering: class {
    
    var isRunning: Bool { get }
    func start()
    func stop()

}

class BTScanner: BTScannering {

    var isRunning: Bool = false

    func start() {

    }

    func stop() {

    }

}
