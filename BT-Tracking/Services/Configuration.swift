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

    let showExposureForDays = 10

    let healthAuthority = "cz.covid19cz.erouska.dev"

    let uploadURL = URL(string: "https://exposure-i5jzq6zlxq-ew.a.run.app/v1/publish")!

    let downloadsURL = URL(string: "https://storage.googleapis.com/exposure-notification-export-ejjud/")!

    let verificationURL = URL(string: "https://apiserver-eyrqoibmxa-ew.a.run.app")!

    let chatbotURL = URL(string: "https://erouska.cz/#chat-open")!

    let verificationAdminKey: String = ""
    let verificationDeviceKey: String = "Ar9VQ1tZS1ANU0LLPGw8nUnavJNBDCaTGEaEQbydvTYFgnW7oqQkTCLUxhk6azLm8IjTtCRVqQIi/wNscvniGw"

}

struct ExposureConfiguration {

    let factorHigh = 0.17
    let factorStandard = 1
    let factorLow = 1.5
    let lowerThreshold = 55
    let higherThreshold = 63
    let triggerThreshold = 15

    var configuration: ENExposureConfiguration {
        let configuration = ENExposureConfiguration()
        configuration.minimumRiskScore = 0
        configuration.attenuationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8] as [NSNumber]
        configuration.daysSinceLastExposureLevelValues = [1, 2, 3, 4, 5, 6, 7, 8] as [NSNumber]
        configuration.durationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8] as [NSNumber]
        configuration.transmissionRiskLevelValues = [1, 2, 3, 4, 5, 6, 7, 8] as [NSNumber]
        configuration.metadata = ["attenuationDurationThresholds": [lowerThreshold, higherThreshold]]
        return configuration
    }

}
