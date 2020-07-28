//
//  FirstActivationVM.swift
// eRouska
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct FirstActivationVM {

    var exposureNotificationAuthorized: Bool {
        return AppDelegate.dependency.exposureService.authorizationStatus == .authorized
    }

    let title = "app_name"

    let back = "back"

    let headline = "welcome_title"

    let body = "welcome_body"

    let moreButton = "welcome_body_more"

    let continueButton = "welcome_activation"

    let howItWorksButton = "welcome_help"

}
