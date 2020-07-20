//
//  UnsupportedDeviceVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 20/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct UnsupportedDeviceVM {

    let headline = "unsupported_device_title"

    let body = "unsupported_device_body"

    let updateButton = "unsupported_device_button"
    // TODO: Use remote config URL
    let moreInfoURL = URL(string: "App-Prefs:root=General")!
}
