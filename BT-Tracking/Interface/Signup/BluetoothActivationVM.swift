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
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .notDetermined
        }
        return CBPeripheralManager.authorizationStatus() == .notDetermined
    }

    var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

    let title = "bluetooth_permission_title"

    let back = "back"

    let help = "help"

    let headline = "bluetooth_permission_headline"

    let body = "bluetooth_permission_body"

    let enableButton = "bluetooth_permission_enable"

}
