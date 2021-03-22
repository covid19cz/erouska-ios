//
//  Device.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 20/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

extension UIDevice {

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
