//
//  BluetoothActivationVM.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BluetoothActivationVM {

    var bluetoothNotDetermined: Bool {
        return CBCentralManager.authorization == .notDetermined
    }

    var bluetoothAuthorized: Bool {
        return CBCentralManager.authorization == .allowedAlways
    }

    let title = "bluetooth_permission_title"

    let back = "back"

    let help = "help"

    let headline = "bluetooth_permission_headline"

    let body = "bluetooth_permission_body"

    let enableButton = "bluetooth_permission_enable"

}
