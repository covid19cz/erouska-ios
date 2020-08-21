//
//  ExposureNotificationPermissionVM.swift
//  eRouska
//
//  Created by Naim Ashhab on 23/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct ExposurePermissionVM {

    let exposureService: ExposureServicing = AppDelegate.dependency.exposureService

    let title = "exposure_notification_title"

    let back = "back"

    let help = "help"

    let headline = "exposure_notification_headline"

    let body = "exposure_notification_body"

    let continueButton = "exposure_notification_continue"

    let errorRestiredTitle = "exposure_activation_restricted_title"
    let errorRestiredBody = "exposure_activation_restricted_body"
    let errorSettingsTitle = "exposure_activation_restricted_settings_action"
    let errorCancelTitle = "exposure_activation_restricted_cancel_action"

    let errorUnknownTitle = "exposure_activation_unknown_title"
    let errorUnknownBody = "exposure_activation_unknown_body"

}
