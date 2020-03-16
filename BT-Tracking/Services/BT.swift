//
//  BT.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

enum CB: String {
    case transferService = "F88F70C1-AADF-4A94-9FF2-35475EF57E21"
    case transferCharacteristic = "1A38B500-C8AB-4222-A9D4-1D5DB152D4C2"
    case broadcastCharacteristic = "08590F7E-DB05-467E-8757-72F6FAEB13D4"

    var cbUUID: CBUUID {
        CBUUID(string: rawValue)
    }
}
