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

    func toExposure() -> Exposure {
        return Exposure(
            date: date,
            duration: duration,
            totalRiskScore: ENRiskScore(totalRiskScore),
            transmissionRiskLevel: ENRiskLevel(transmissionRiskLevel),
            attenuationValue: ENAttenuation(attenuationValue),
            attenuationDurations: attenuationDurations.toArray()
        )
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
