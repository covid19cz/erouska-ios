//
//  RiskyEncountersNegativeVM.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 25/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift
import UIKit

struct RiskyEncountersNegativeVM {
    let shouldShowPreviousRiskyEncounters: Observable<Bool>

    let title = RemoteValues.exposureUITitle

    let negativeTitle = RemoteValues.noEncounterHeader
    let negativeBody = RemoteValues.noEncounterBody

    let previousRiskyEncountersButton = RemoteValues.recentExposuresUITitle

    init() {
        let realm = AppDelegate.dependency.realm
        let exposures = realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")

        shouldShowPreviousRiskyEncounters = Observable.collection(from: exposures).map {
            !$0.isEmpty
        }
    }
}
