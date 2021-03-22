//
//  UnsupportedDeviceVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 20/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct UnsupportedDeviceVM {

    let headline = UIDevice.current.modelName.hasPrefix("iPad") ? L10n.unsupportedDeviceIpadTitle : L10n.unsupportedDeviceTitle

    let body = UIDevice.current.modelName.hasPrefix("iPad") ? L10n.unsupportedDeviceIpadBody : L10n.unsupportedDeviceBody

    let moreInfoButton = L10n.unsupportedDeviceButton
}
