//
//  ExposureNotificationPermissionVM.swift
// eRouska
//
//  Created by Naim Ashhab on 23/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct ExposureNotificationPermissionVM {

    let exposureService: ExposureServicing = AppDelegate.dependency.exposureService

    let title = "exposure_notification_title"

    let back = "back"

    let help = "help"

    let headline = "exposure_notification_headline"

    let body = "exposure_notification_body"

    let continueButton = "exposure_notification_continue"
}
