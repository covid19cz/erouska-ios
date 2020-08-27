//
//  PreviousRiskyEncountersVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

struct PreviousRiskyEncountersVM {
    let previousExposures: Observable<[Exposure]>

    let title = RemoteValues.recentExposuresUITitle

    init() {
        let realm = try! Realm()
        let exposures = realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")
        previousExposures = Observable.collection(from: exposures)
            .map { collection in
                collection.toArray().map { $0.toExposure() }
            }
    }
}
