//
//  BTAdvertiser.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

protocol BTAdvertising: class {

    var isRunning: Bool { get }
    func start()
    func stop()
    
}

class BTAdvertiser: BTAdvertising {

    var isRunning: Bool = false

    func start() {

    }

    func stop() {
        
    }

}
