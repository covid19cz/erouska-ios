//
//  BT.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth

enum BT: String {
    case advertiserName = "Covid-19"

    case transferService = "1440dd68-67e4-11ea-bc55-0242ac130003"
    case transferCharacteristic = "9472fbde-04ff-4fff-be1c-b9d3287e8f28"
    case broadcastCharacteristic = "08590F7E-DB05-467E-8757-72F6FAEB13D4"

    case appleService = "816C6CA9-50AE-4D0A-841A-C44BCE1D1DBB"

    var cbUUID: CBUUID {
        CBUUID(string: rawValue)
    }
}

var BTDeviceName: String {
    let versionName = "SC19" // Stop covid 19
    let version = "\(App.appVersion)_\(App.bundleBuild)"
    return "\(versionName)/\(version);(\(UIDevice.current.systemName);\(UIDevice.current.systemVersion);Apple;\(UIDevice.current.model);"
}
