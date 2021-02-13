//
//  ExposureEntities.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 21/05/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification

enum ExposureError: Error {
    case bluetoothOff
    case restrictedAccess
    case noData
    case unknown
    case alreadyRunning
    case error(Error)
    case activationError(ENError.Code)

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
        case .activationError:
            return "activationError"
        }
    }
}

protocol ExposureConfiguration: Decodable {

    var configuration: ENExposureConfiguration { get }

}

struct ExposureConfigurationV1: ExposureConfiguration, Decodable {

    let factorHigh: Double
    let factorStandard: Double
    let factorLow: Double
    let lowerThreshold: Int
    let higherThreshold: Int
    let triggerThreshold: Int

    init() {
        factorHigh = 0.17
        factorStandard = 1
        factorLow = 1.5
        lowerThreshold = 55
        higherThreshold = 63
        triggerThreshold = 15
    }

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

struct ExposureConfigurationV2: ExposureConfiguration, Decodable {

    // API V2 Keys
    let immediateDurationWeight: Double
    let nearDurationWeight: Double
    let mediumDurationWeight: Double
    let otherDurationWeight: Double
    let infectiousnessForDaysSinceOnsetOfSymptoms: [String: Int]
    let infectiousnessStandardWeight: Double
    let infectiousnessHighWeight: Double
    let reportTypeConfirmedTestWeight: Double
    let reportTypeConfirmedClinicalDiagnosisWeight: Double
    let reportTypeSelfReportedWeight: Double
    let reportTypeRecursiveWeight: Double
    let reportTypeNoneMap: Int

    // API V1 Keys
    let minimumRiskScore: ENRiskScore
    let attenuationDurationThresholds: [Int]
    let attenuationLevelValues: [ENRiskLevelValue]
    let daysSinceLastExposureLevelValues: [ENRiskLevelValue]
    let durationLevelValues: [ENRiskLevelValue]
    let transmissionRiskLevelValues: [ENRiskLevelValue]

    init() {
        immediateDurationWeight = 150
        nearDurationWeight = 100
        mediumDurationWeight = 17
        otherDurationWeight = 0
        var infectiousness: [String: Int] = [:]
        for i in -14...(-3) {
            infectiousness[String(i)] = 0 // ENInfectiousness.none
        }
        for i in -2...14 {
            infectiousness[String(i)] = 1 // ENInfectiousness.standard
        }
        infectiousness["unknown"] = 1
        infectiousnessForDaysSinceOnsetOfSymptoms = infectiousness
        infectiousnessStandardWeight = 100
        infectiousnessHighWeight = 100
        reportTypeConfirmedTestWeight = 100
        reportTypeConfirmedClinicalDiagnosisWeight = 100
        reportTypeSelfReportedWeight = 100
        reportTypeRecursiveWeight = 100
        reportTypeNoneMap = 1 // ENDiagnosisReportType.confirmedTest.rawValue
        minimumRiskScore = 0
        attenuationDurationThresholds = [55, 63, 75]
        attenuationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        daysSinceLastExposureLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        durationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
        transmissionRiskLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
    }

    var configuration: ENExposureConfiguration {
        let configuration = ENExposureConfiguration()
        if #available(iOS 13.7, *) {
            configuration.immediateDurationWeight = immediateDurationWeight
            configuration.nearDurationWeight = nearDurationWeight
            configuration.mediumDurationWeight = mediumDurationWeight
            configuration.otherDurationWeight = otherDurationWeight
            var infectiousnessForDaysSinceOnsetOfSymptoms: [Int: Int] = [:]
            for (stringDay, infectiousness) in self.infectiousnessForDaysSinceOnsetOfSymptoms {
                if stringDay == "unknown" {
                    if #available(iOS 14.0, *) {
                        infectiousnessForDaysSinceOnsetOfSymptoms[ENDaysSinceOnsetOfSymptomsUnknown] = infectiousness
                    } else {
                        // ENDaysSinceOnsetOfSymptomsUnknown is not available
                        // in earlier versions of iOS; use an equivalent value
                        infectiousnessForDaysSinceOnsetOfSymptoms[NSIntegerMax] = infectiousness
                    }
                } else if let day = Int(stringDay) {
                    infectiousnessForDaysSinceOnsetOfSymptoms[day] = infectiousness
                }
            }
            configuration.infectiousnessForDaysSinceOnsetOfSymptoms = infectiousnessForDaysSinceOnsetOfSymptoms as [NSNumber: NSNumber]
            configuration.infectiousnessStandardWeight = infectiousnessStandardWeight
            configuration.infectiousnessHighWeight = infectiousnessHighWeight
            configuration.reportTypeConfirmedTestWeight = reportTypeConfirmedTestWeight
            configuration.reportTypeConfirmedClinicalDiagnosisWeight = reportTypeConfirmedClinicalDiagnosisWeight
            configuration.reportTypeSelfReportedWeight = reportTypeSelfReportedWeight
            configuration.reportTypeRecursiveWeight = reportTypeRecursiveWeight
            if let reportTypeNoneMap = ENDiagnosisReportType(rawValue: UInt32(reportTypeNoneMap)) {
                configuration.reportTypeNoneMap = reportTypeNoneMap
            }
        }
        configuration.minimumRiskScore = minimumRiskScore
        configuration.attenuationLevelValues = attenuationLevelValues as [NSNumber]
        configuration.daysSinceLastExposureLevelValues = daysSinceLastExposureLevelValues as [NSNumber]
        configuration.durationLevelValues = durationLevelValues as [NSNumber]
        configuration.transmissionRiskLevelValues = transmissionRiskLevelValues as [NSNumber]
        configuration.metadata = ["attenuationDurationThresholds": attenuationDurationThresholds]
        return configuration
    }

}

struct Exposure: Codable, Equatable {

    let id: UUID
    let date: Date
    let duration: TimeInterval
    let totalRiskScore: ENRiskScore
    let transmissionRiskLevel: ENRiskLevel
    let attenuationValue: ENAttenuation
    var attenuationDurations: [Int]
    var window: ExposureWindow?

    func computedThreshold(with configuration: ExposureConfiguration) -> Double {
        switch configuration {
        case let configuration as ExposureConfigurationV1:
            return (Double(truncating: attenuationDurations[0] as NSNumber) * configuration.factorLow +
                        Double(truncating: attenuationDurations[1] as NSNumber) * configuration.factorHigh) / 60 // (minute)
        case is ExposureConfigurationV2:
            return 0
        default:
            return 0
        }
    }

    static func debugExposure(date: Date = Date()) -> Exposure {
        return Self(
            id: UUID(),
            date: date,
            duration: 213,
            totalRiskScore: 2,
            transmissionRiskLevel: 4,
            attenuationValue: 4,
            attenuationDurations: [21, 1, 4, 5],
            window: nil
        )
    }

}

struct ExposureWindow: Codable, Equatable {
    init(id: UUID, date: Date, calibrationConfidence: Int, diagnosisReportType: Int, infectiousness: Int, scanInstances: [ExposureWindow.Scan]) {
        self.id = id
        self.date = date
        self.calibrationConfidence = calibrationConfidence
        self.diagnosisReportType = diagnosisReportType
        self.infectiousness = infectiousness
        self.scanInstances = scanInstances
    }


    struct Scan: Codable, Equatable {
        var minimumAttenuation: Int
        var typicalAttenuation: Int
        var secondsSinceLastScan: Int

        init(minimumAttenuation: Int, typicalAttenuation: Int, secondsSinceLastScan: Int) {
            self.minimumAttenuation = minimumAttenuation
            self.typicalAttenuation = typicalAttenuation
            self.secondsSinceLastScan = secondsSinceLastScan
        }
    }

    var id: UUID
    var date: Date
    var calibrationConfidence: Int
    var diagnosisReportType: Int
    var infectiousness: Int
    var scanInstances: [Scan]

}

struct ExposureDiagnosisKey: Codable, Equatable {

    /// Key must be the base64 (RFC 4648) encoded 16 byte exposure key from the device.
    let keyData: Data

    /// Must >= `minIntervalCount` and <= `maxIntervalCount` 1 - 144 inclusive.
    let rollingPeriod: ENIntervalNumber

    /// Must be "reasonable" as in the system won't accept keys that
    /// are scheduled to start in the future or that are too far in the past, which is configurable per installation.
    let rollingStartNumber: ENIntervalNumber

    /// transmissionRisk must be >= 0 and <= 8. Transmission risk is optional, but should still be populated for compatibility
    /// with older clients. If it is omitted, and there is a valid report type, then transmissionRisk will be set to 0.
    let transmissionRiskLevel: ENRiskLevel

    private enum CodingKeys: String, CodingKey {
        case keyData = "key"
        case rollingPeriod
        case rollingStartNumber
        case transmissionRiskLevel = "transmissionRisk"
    }

    init(key: ENTemporaryExposureKey) {
        self.keyData = key.keyData
        self.rollingPeriod = key.rollingPeriod
        self.rollingStartNumber = key.rollingStartNumber
        self.transmissionRiskLevel = key.transmissionRiskLevel
    }

}
