//
//  ExposureEntities.swift
// eRouska
//
//  Created by Lukáš Foldýna on 21/05/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification
import RealmSwift

enum ExposureError: Error {
    case bluetoothOff
    case restrictedAccess
    case noData
    case unknown
    case alreadyRunning
    case error(Error)

    var key: String {
        switch self {
        case .bluetoothOff:
            return "bluetoothOff"
        case .restrictedAccess:
            return "restrictedAccess"
        case .noData:
            return "noData"
        case .unknown:
            return "unknown"
        case .alreadyRunning:
            return "alreadyRunning"
        case .error:
            return "error"
        }
    }
}

struct Exposure: Codable, Equatable {
    let date: Date
    let duration: TimeInterval
    let totalRiskScore: ENRiskScore
    let transmissionRiskLevel: ENRiskLevel
    let attenuationValue: ENAttenuation
    var attenuationDurations: [Int]
}

final class ExposureRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var date: Date = Date()

    // Need to save all properties?
    @objc dynamic var duration: Double = 0
    @objc dynamic var totalRiskScore: Int = 0
    @objc dynamic var transmissionRiskLevel: Int = 0
    @objc dynamic var attenuationValue: Int = 0
    let attenuationDurations = List<Int>()

    override class func primaryKey() -> String {
        return "id"
    }

    convenience init(_ exposure: Exposure) {
        self.init()

        id = UUID().uuidString
        date = exposure.date
        duration = exposure.duration
        totalRiskScore = Int(exposure.totalRiskScore)
        transmissionRiskLevel = Int(exposure.transmissionRiskLevel)
        attenuationValue = Int(exposure.attenuationValue)
        attenuationDurations.append(objectsIn: exposure.attenuationDurations)
    }
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
