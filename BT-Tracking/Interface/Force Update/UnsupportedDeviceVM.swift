//
//  UnsupportedDeviceVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 20/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct UnsupportedDeviceVM {

    let headline = UIDevice.current.modelName.hasPrefix("iPad") ? "unsupported_device_ipad_title" : "unsupported_device_title"

    let body = UIDevice.current.modelName.hasPrefix("iPad") ? "unsupported_device_ipad_body" : "unsupported_device_body"

    let moreInfoButton = "unsupported_device_button"
}
