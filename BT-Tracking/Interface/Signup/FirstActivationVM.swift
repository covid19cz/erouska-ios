//
//  FirstActivationVM.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreBluetooth

struct FirstActivationVM {

    var bluetoothAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

    let title = "app_name"

    let back = "back"

    let headline = "welcome_title"

    let body = "welcome_body"

    let moreButton = "welcome_body_more"

    let continueButton = "welcome_activation"

    let howItWorksButton = "welcome_help"

}
