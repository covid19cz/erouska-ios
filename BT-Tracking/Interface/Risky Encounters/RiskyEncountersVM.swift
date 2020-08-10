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

    init() {
        guard let lastPossibleDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) else { return }

        let realm = try! Realm()
        riskyEncouterDateToShow = realm.objects(ExposureRealm.self)
            .sorted(byKeyPath: "date")
            .filter { $0.date > lastPossibleDate }
            .first?
            .date
    }
}
