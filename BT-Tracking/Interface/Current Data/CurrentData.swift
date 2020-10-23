//
//  CurrentData.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 26/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift

final class CurrentDataRealm: Object {

    @objc dynamic var testsTotal: Int = 0
    @objc dynamic var testsIncrease: Int = 0
    @objc dynamic var confirmedCasesTotal: Int = 0
    @objc dynamic var confirmedCasesIncrease: Int = 0
    @objc dynamic var activeCasesTotal: Int = 0
    @objc dynamic var curedTotal: Int = 0
    @objc dynamic var deceasedTotal: Int = 0
    @objc dynamic var currentlyHospitalizedTotal: Int = 0

    @objc dynamic var appDate: Date?
    @objc dynamic var activationsYesterday: Int = 0
    @objc dynamic var activationsTotal: Int = 0
    @objc dynamic var keyPublishersYesterday: Int = 0
    @objc dynamic var keyPublishersTotal: Int = 0
    @objc dynamic var notificationsYesterday: Int = 0
    @objc dynamic var notificationsTotal: Int = 0

    convenience init(
        testsTotal: Int,
        testsIncrease: Int,
        confirmedCasesTotal: Int,
        confirmedCasesIncrease: Int,
        activeCasesTotal: Int,
        curedTotal: Int,
        deceasedTotal: Int,
        currentlyHospitalizedTotal: Int,
        appDate: Date?,
        activationsYesterday: Int,
        activationsTotal: Int,
        keyPublishersYesterday: Int,
        keyPublishersTotal: Int,
        notificationsYesterday: Int,
        notificationsTotal: Int
    ) {
        self.init()

        self.testsTotal = testsTotal
        self.testsIncrease = testsIncrease
        self.confirmedCasesTotal = confirmedCasesTotal
        self.confirmedCasesIncrease = confirmedCasesIncrease
        self.activeCasesTotal = activeCasesTotal
        self.curedTotal = curedTotal
        self.deceasedTotal = deceasedTotal
        self.currentlyHospitalizedTotal = currentlyHospitalizedTotal

        self.appDate = appDate
        self.activationsYesterday = activationsYesterday
        self.activationsTotal = activationsTotal
        self.keyPublishersYesterday = keyPublishersYesterday
        self.keyPublishersTotal = keyPublishersTotal
        self.notificationsYesterday = notificationsYesterday
        self.notificationsTotal = notificationsTotal
    }

    func update(with data: [String: Any]) {
        if let value = data["testsTotal"] as? Int { testsTotal = value }
        if let value = data["testsIncrease"] as? Int { testsIncrease = value }
        if let value = data["confirmedCasesTotal"] as? Int { confirmedCasesTotal = value }
        if let value = data["confirmedCasesIncrease"] as? Int { confirmedCasesIncrease = value }
        if let value = data["activeCasesTotal"] as? Int { activeCasesTotal = value }
        if let value = data["curedTotal"] as? Int { curedTotal = value }
        if let value = data["deceasedTotal"] as? Int { deceasedTotal = value }
        if let value = data["currentlyHospitalizedTotal"] as? Int { currentlyHospitalizedTotal = value }
    }

    func update(with data: AppCurrentData) {
        self.appDate = data.date
        self.activationsYesterday = data.activationsYesterday
        self.activationsTotal = data.activationsTotal
        self.keyPublishersYesterday = data.keyPublishersYesterday
        self.keyPublishersTotal = data.keyPublishersTotal
        self.notificationsYesterday = data.notificationsYesterday
        self.notificationsTotal = data.notificationsTotal
    }

}

struct AppCurrentData: Decodable {

    let modified: Int
    let date: Date?
    let activationsYesterday: Int
    let activationsTotal: Int
    let keyPublishersYesterday: Int
    let keyPublishersTotal: Int
    let notificationsYesterday: Int
    let notificationsTotal: Int

    private enum CodingKeys: String, CodingKey {
        case modified, date
        case activationsYesterday = "activations_yesterday"
        case activationsTotal = "activations_total"
        case keyPublishersYesterday = "key_publishers_yesterday"
        case keyPublishersTotal = "key_publishers_total"
        case notificationsYesterday = "notifications_yesterday"
        case notificationsTotal = "notifications_total"
    }

}
