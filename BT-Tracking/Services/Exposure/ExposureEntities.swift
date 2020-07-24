//
//  ExposureEntities.swift
// eRouska
//
//  Created by Lukáš Foldýna on 21/05/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification

enum ExposureError: String, Error {
    case bluetoothOff
    case restrictedAccess
    case noData
    case unknown
    case alreadyRunning
}

struct Exposure: Codable, Equatable {
    let date: Date
    let duration: TimeInterval
    let totalRiskScore: ENRiskScore
    let transmissionRiskLevel: ENRiskLevel
    let attenuationValue: ENAttenuation
    var attenuationDurations: [Int]
}

struct ExposureConfiguration: Codable {
    let minimumRiskScore: ENRiskScore
    let attenuationDurationThresholds: [Int]
    let attenuationLevelValues: [ENRiskLevelValue]
    let daysSinceLastExposureLevelValues: [ENRiskLevelValue]
    let durationLevelValues: [ENRiskLevelValue]
    let transmissionRiskLevelValues: [ENRiskLevelValue]
}

struct ExposureDiagnosisKey: Codable, Equatable {
    let keyData: Data
    let rollingPeriod: ENIntervalNumber
    let rollingStartNumber: ENIntervalNumber
    let transmissionRiskLevel: ENRiskLevel

    init(key: ENTemporaryExposureKey) {
        self.keyData = key.keyData
        self.rollingPeriod = key.rollingPeriod
        self.rollingStartNumber = key.rollingStartNumber
        self.transmissionRiskLevel = key.transmissionRiskLevel
    }
}
