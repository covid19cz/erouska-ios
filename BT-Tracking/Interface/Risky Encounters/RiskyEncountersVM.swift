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
import UIKit

struct RiskyEncountersVM {
    enum MenuItem {
        case mainSymptoms, preventTransmission, previousRiskyEncounters

        var icon: UIImage {
            switch self {
            case .mainSymptoms:
                return Asset.mainSymptoms.image
            case .preventTransmission:
                return Asset.preventTransmission.image
            case .previousRiskyEncounters:
                return Asset.previousRiskyEncounters.image
            }
        }

        var localizedTitle: String {
            switch self {
            case .mainSymptoms:
                return RemoteValues.symptomsUITitle
            case .preventTransmission:
                return RemoteValues.spreadPreventionUITitle
            case .previousRiskyEncounters:
                return RemoteValues.recentExposuresUITitle
            }
        }
    }

    let menuItems = [MenuItem.mainSymptoms, .preventTransmission, .previousRiskyEncounters]

    let riskyEncounterDateToShow: Observable<Date?>
    let shouldShowPreviousRiskyEncounters: Observable<Bool>

    let title = RemoteValues.exposureUITitle

    let withSymptoms = RemoteValues.riskyEncountersWithSymptoms
    let withoutSymptoms = RemoteValues.riskyEncountersWithoutSymptoms

    let negativeTitle = RemoteValues.noEncounterHeader
    let negativeBody = RemoteValues.noEncounterBody

    let previousRiskyEncountersButton = RemoteValues.recentExposuresUITitle

    init() {
        let showForDays = RemoteValues.serverConfiguration.showExposureForDays
        let realm = AppDelegate.dependency.realm
        let exposures = realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")

        let showForDate = Calendar.current.date(byAdding: .day, value: -showForDays, to: Date()) ?? Date()
        riskyEncounterDateToShow = Observable.collection(from: exposures).map {
            $0.last(where: { $0.date > showForDate })?.date
        }

        shouldShowPreviousRiskyEncounters = Observable.collection(from: exposures).map {
            !$0.isEmpty
        }
    }
}
