//
//  FirstActivationVM.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct FirstActivationVM {

    var exposureNotificationAuthorized: Bool {
        AppDelegate.dependency.exposure.authorizationStatus == .authorized
    }

}
