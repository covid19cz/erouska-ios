//
//  RiskyEncountersVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift

struct RiskyEncountersVM {
    let riskyEncouterDateToShow: Observable<Date?>
    let shouldShowPreviousRiskyEncounters: Observable<Bool>

    let title = "risky_encounters_title"
    let headline = RemoteValues.riskyEncountersTitle
    let body = RemoteValues.riskyEncountersBody

    init() {
        let realm = try! Realm()
        let exposures = realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")
        riskyEncouterDateToShow = Observable.collection(from: exposures)
            .map {
                $0.filter { $0.date > Calendar.current.date(byAdding: .day, value: -14, to: Date())! }.first?.date
            }

        shouldShowPreviousRiskyEncounters = Observable.collection(from: exposures)
            .map {
                !$0.isEmpty
            }
    }
}
