//
//  ExposureNotificationPermissionVM.swift
//  eRouska
//
//  Created by Naim Ashhab on 23/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct ExposurePermissionVM {

    var exposureService: ExposureServicing {
        AppDelegate.dependency.exposureService
    }

}
