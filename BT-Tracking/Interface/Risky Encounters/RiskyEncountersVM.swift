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
    let riskyEcountersInTimeInterval: Observable<Int>
    let shouldShowPreviousRiskyEncounters: Observable<Bool>

    let title = RemoteValues.exposureUITitle

    let withSymptoms = RemoteValues.riskyEncountersWithSymptoms
    let withoutSymptoms = RemoteValues.riskyEncountersWithoutSymptoms

    let negativeTitle = RemoteValues.noEncounterHeader
    let negativeBody = RemoteValues.noEncounterBody

    let previousRiskyEncountersButton = RemoteValues.recentExposuresUITitle

    init() {
        let showForDays = RemoteValues.serverConfiguration.showExposureForDays
        let realm = try? Realm()
        guard let exposures = realm?.objects(ExposureRealm.self).sorted(byKeyPath: "date") else {
            riskyEncounterDateToShow = .empty()
            riskyEcountersInTimeInterval = .of(0)
            shouldShowPreviousRiskyEncounters = .of(false)
            return
        }

        let showForDate = Calendar.current.date(byAdding: .day, value: -showForDays, to: Date()) ?? Date()
        let riskyEcounters = Observable.collection(from: exposures)
        let filteredRiskyEcounters = riskyEcounters.map { $0.filter { $0.date > showForDate } }
        riskyEncounterDateToShow = filteredRiskyEcounters.map { $0.last?.date }
        riskyEcountersInTimeInterval = filteredRiskyEcounters.map { $0.count }
        shouldShowPreviousRiskyEncounters = riskyEcounters.map { !$0.isEmpty }
    }
}
