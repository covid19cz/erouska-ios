//
//  Configuration.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 17/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification

struct Configuration {

    let minSupportedVersion = "13.5"

    let showExposureForDays = 14

    var healthAuthority: String {
        #if PROD
        return "cz.covid19cz.erouska"
        #else
        return "cz.covid19cz.erouska.dev"
        #endif
    }

    var uploadURL: URL {
        #if PROD
        return URL(string: "https://exposure-fghz64a2xa-ew.a.run.app/v1/publish")!
        #else
        return URL(string: "https://exposure-i5jzq6zlxq-ew.a.run.app/v1/publish")!
        #endif
    }

    var downloadIndexName: String {
        #if PROD
        return "erouska/index.txt"
        #else
        return "/index.txt"
        #endif
    }

    var downloadsURL: URL {
        #if PROD
        return URL(string: "https://storage.googleapis.com/exposure-notification-export-qhqcx/")!
        #else
        return URL(string: "https://storage.googleapis.com/exposure-notification-export-ejjud/")!
        #endif
    }

    var verificationURL: URL {
        #if PROD
        return URL(string: "https://apiserver-jyvw4xgota-ew.a.run.app")!
        #else
        return URL(string: "https://apiserver-eyrqoibmxa-ew.a.run.app")!
        #endif
    }

    let verificationAdminKey: String = ""
    var verificationDeviceKey: String {
        return RemoteValues.verificationServerApiKey
    }

}
