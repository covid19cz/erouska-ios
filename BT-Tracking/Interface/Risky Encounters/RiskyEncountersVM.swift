//
//  RiskyEncountersVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift

struct RiskyEncountersVM {
    var riskyEncouterDateToShow: Date?

    let title = "risky_encounters_title"
    let headline: String
    let body = RemoteValues.riskyEncountersBody

    init() {
        guard let lastPossibleDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) else {
            headline = ""
            return
        }

        let realm = try! Realm()
        let exposures = realm.objects(ExposureRealm.self)
            .sorted(byKeyPath: "date")
            .filter { $0.date > lastPossibleDate }

        riskyEncouterDateToShow = exposures.first?.date

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MM. yyyy"
        if let date = riskyEncouterDateToShow {
            headline = String(format: RemoteValues.riskyEncountersTitle, dateFormatter.string(from: date))
        } else {
            headline = ""
        }
    }
}
