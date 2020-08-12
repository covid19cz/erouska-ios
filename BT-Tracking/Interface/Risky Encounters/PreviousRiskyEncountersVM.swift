//
//  PreviousRiskyEncountersVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift

struct PreviousRiskyEncountersVM {
    let previousExposures: [Exposure]

    let title = "previous_risky_encounters_title"

    init() {
        let realm = try! Realm()
        previousExposures = realm.objects(ExposureRealm.self)
            .sorted(byKeyPath: "date")
            .map { $0.toExposure() }
    }
}
