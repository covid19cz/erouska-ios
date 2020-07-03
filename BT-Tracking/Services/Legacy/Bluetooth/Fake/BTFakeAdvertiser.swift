//
//  BTFakeAdvertiser.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 21/05/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTFakeAdvertiser: BTAdvertising {

    @available(iOS 13.0, *)
    var authorization: CBManagerAuthorization {
        return .allowedAlways
    }

    var currentID: String?

    var didChangeID: IDChangeCallback?

    var isRunning: Bool = false

    required init(TUIDs: [String], IDRotation: Int) {

    }

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }
    
}
