//
//  ForceOSUpdateVM.swift
//  eRouska
//
//  Created by Naim Ashhab on 17/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct ForceOSUpdateVM {

    let headline = "force_os_update_title"

    let body = "force_os_update_body"

    let updateButton = "force_update_button"
    // swiftlint:disable:next force_unwrapping
    let settingsURL = URL(string: UIApplication.openSettingsURLString)!
}
