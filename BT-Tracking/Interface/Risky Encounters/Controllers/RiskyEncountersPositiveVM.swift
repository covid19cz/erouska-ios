//
//  RiskyEncountersPositiveVM.swift
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

struct RiskyEncountersPositiveVM {
    enum Sections {
        case encounter, withSymptoms, withoutSymptoms

        var icon: UIImage {
            switch self {
            case .encounter:
                return Asset.previousRiskyEncounters.image
            case .withSymptoms:
                return Asset.mainSymptoms.image
            case .withoutSymptoms:
                return Asset.preventTransmission.image
            }
        }

        var localizedSection: String? {
            switch self {
            case .encounter:
                return nil
            case .withSymptoms:
                return L10n.riskyEncountersPositiveWithSymptomsHeader
            case .withoutSymptoms:
                return L10n.riskyEncountersPositiveWithoutSymptomsHeader
            }
        }

        var localizedText: String {
            switch self {
            case .encounter:
                return L10n.riskyEncountersPositiveWithSymptomsHeader
            case .withSymptoms:
                return RemoteValues.riskyEncountersWithSymptoms
            case .withoutSymptoms:
                return RemoteValues.riskyEncountersWithoutSymptoms
            }
        }

        var localizedTitle: String {
            switch self {
            case .encounter:
                return RemoteValues.recentExposuresUITitle
            case .withSymptoms:
                return RemoteValues.symptomsUITitle
            case .withoutSymptoms:
                return RemoteValues.spreadPreventionUITitle
            }
        }
    }

    let sections = [Sections.encounter, .withSymptoms, .withoutSymptoms]

    let riskyEncounterDateToShow: Observable<Date?>
    let shouldShowPreviousRiskyEncounters: Observable<Bool>

    let title = RemoteValues.exposureUITitle

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
