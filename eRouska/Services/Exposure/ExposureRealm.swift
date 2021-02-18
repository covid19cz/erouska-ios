//
//  ExposureRealm.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 15/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import ExposureNotification

final class ExposureRealm: Object {
    @objc dynamic var id: String
    @objc dynamic var date: Date
    @objc dynamic var detectedDate: Date

    @objc dynamic var dataV1: ExposureDataV1?
    @objc dynamic var dataV2: ExposureDataV2?

    var attenuationDurations: List<Int> = .init() // legacy remove in future

    override class func primaryKey() -> String {
        return "id"
    }

    required init() {
        id = UUID().uuidString
        date = Date()
        detectedDate = Date()
        super.init()
    }

    convenience init(_ exposure: Exposure, detectedDate: Date) {
        self.init()

        self.id = exposure.id.uuidString
        self.date = exposure.date
        self.detectedDate = detectedDate

        self.dataV1 = .init(exposure)
    }

    convenience init(_ exposure: ExposureWindow, detectedDate: Date) {
        self.init()

        self.id = UUID().uuidString
        self.date = exposure.date
        self.detectedDate = detectedDate

        self.dataV1 = .init()
        self.dataV2 = .init(exposure)
    }

    func toExposure() -> Exposure? {
        var exposure = dataV1?.toExposure(date: date)
        exposure?.window = toWindowExposure()
        return exposure
    }

    func toWindowExposure() -> ExposureWindow? {
        return dataV2?.toExposure(date: date)
    }
}

final class ExposureDataV1: Object {

    @objc dynamic var id: String
    @objc dynamic var duration: Double
    @objc dynamic var totalRiskScore: Int
    @objc dynamic var transmissionRiskLevel: Int
    @objc dynamic var attenuationValue: Int
    var attenuationDurations: List<Int>

    override class func primaryKey() -> String {
        return "id"
    }

    required init() {
        id = UUID().uuidString
        duration = 0
        totalRiskScore = 0
        transmissionRiskLevel = 0
        attenuationValue = 0
        attenuationDurations = List<Int>()
        super.init()
    }

    convenience init(_ exposure: Exposure) {
        self.init()

        duration = exposure.duration
        totalRiskScore = Int(exposure.totalRiskScore)
        transmissionRiskLevel = Int(exposure.transmissionRiskLevel)
        attenuationValue = Int(exposure.attenuationValue)
        attenuationDurations.append(objectsIn: exposure.attenuationDurations)
    }

    func toExposure(date: Date) -> Exposure {
        return Exposure(
            id: UUID(uuidString: id) ?? UUID(),
            date: date,
            duration: duration,
            totalRiskScore: ENRiskScore(totalRiskScore),
            transmissionRiskLevel: ENRiskLevel(transmissionRiskLevel),
            attenuationValue: ENAttenuation(attenuationValue),
            attenuationDurations: attenuationDurations.toArray(),
            window: nil
        )
    }

}

final class ExposureDataV2: Object {

    @objc dynamic var id: String
    @objc dynamic var calibrationConfidence: Int
    @objc dynamic var diagnosisReportType: Int
    @objc dynamic var infectiousness: Int
    var minimumAttenuation: List<Int>
    var typicalAttenuation: List<Int>
    var secondsSinceLastScan: List<Int>

    @objc dynamic var maximumScore: Double
    @objc dynamic var scoreSum: Double
    @objc dynamic var weightedDurationSum: Double

    override class func primaryKey() -> String {
        return "id"
    }

    required init() {
        id = UUID().uuidString
        calibrationConfidence = 0
        diagnosisReportType = 0
        infectiousness = 0
        minimumAttenuation = List<Int>()
        typicalAttenuation = List<Int>()
        secondsSinceLastScan = List<Int>()
        maximumScore = 0
        scoreSum = 0
        weightedDurationSum = 0
        super.init()
    }

    convenience init(_ exposure: ExposureWindow) {
        self.init()

        calibrationConfidence = exposure.calibrationConfidence
        diagnosisReportType = exposure.diagnosisReportType
        infectiousness = exposure.infectiousness
        for scan in exposure.scanInstances {
            minimumAttenuation.append(scan.minimumAttenuation)
            typicalAttenuation.append(scan.typicalAttenuation)
            secondsSinceLastScan.append(scan.secondsSinceLastScan)
        }
        maximumScore = exposure.daySummary?.maximumScore ?? 0
        scoreSum = exposure.daySummary?.scoreSum ?? 0
        weightedDurationSum = exposure.daySummary?.weightedDurationSum ?? 0
    }

    func toExposure(date: Date) -> ExposureWindow {
        var scans: [ExposureWindow.Scan] = []
        for (index, _) in minimumAttenuation.enumerated() {
            scans.append(
                .init(
                    minimumAttenuation: minimumAttenuation[index],
                    typicalAttenuation: typicalAttenuation[index],
                    secondsSinceLastScan: secondsSinceLastScan[index]
                )
            )
        }

        return ExposureWindow(
            id: UUID(uuidString: id) ?? UUID(),
            date: date,
            calibrationConfidence: calibrationConfidence,
            diagnosisReportType: diagnosisReportType,
            infectiousness: infectiousness,
            scanInstances: scans,
            daySummary: .init(maximumScore: maximumScore, scoreSum: scoreSum, weightedDurationSum: weightedDurationSum)
        )
    }

}
