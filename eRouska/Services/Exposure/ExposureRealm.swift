//
//  ExposureRealm.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 15/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift
import ExposureNotification

final class ExposureRealm: Object {
    @objc dynamic var id: String
    @objc dynamic var date: Date
    @objc dynamic var detectedDate: Date

    @objc dynamic var dataV1: ExposureDataV1?

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

    func toExposure() -> Exposure? {
        return dataV1?.toExposure(date: date)
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
            attenuationDurations: attenuationDurations.toArray()
        )
    }
}
