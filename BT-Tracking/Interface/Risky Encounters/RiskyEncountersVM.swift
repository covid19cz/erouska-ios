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
                return UIImage(named: "MainSymptoms")!
            case .preventTransmission:
                return UIImage(named: "PreventTransmission")!
            case .previousRiskyEncounters:
                return UIImage(named: "PreviousRiskyEncounters")!
            }
        }

        var localizedTitle: String {
            switch self {
            case .mainSymptoms:
                return Localizable("main_symptoms_title")
            case .preventTransmission:
                return Localizable("prevent_transmission_title")
            case .previousRiskyEncounters:
                return Localizable("previous_risky_encounters_title")
            }
        }
    }

    let menuItems = [MenuItem.mainSymptoms, .preventTransmission, .previousRiskyEncounters]

    let riskyEncouterDateToShow: Observable<Date?>
    let shouldShowPreviousRiskyEncounters: Observable<Bool>

    let title = "risky_encounters_title"

    let withSymptomsHeaderKey = "risky_encounters_positive_with_symptoms_header"
    let withSymptoms = RemoteValues.riskyEncountersWithSymptoms
    let withoutSymptomsHeaderKey = "risky_encounters_positive_without_symptoms_header"
    let withoutSymptoms = RemoteValues.riskyEncountersWithoutSymptoms

    let negativeTitleKey = "risky_encounters_negative_title"
    let negativeBodyKey = "risky_encounters_negative_body"

    let previousRiskyEncountersButtonKey = "previous_risky_encounters_title"

    init() {
        let showForDays = AppDelegate.dependency.configuration.showExposureForDays
        let realm = try! Realm()
        let exposures = realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")
        riskyEncouterDateToShow = Observable.collection(from: exposures)
            .map {
                $0.filter { $0.date > Calendar.current.date(byAdding: .day, value: -showForDays, to: Date())! }.first?.date
            }

        shouldShowPreviousRiskyEncounters = Observable.collection(from: exposures)
            .map {
                !$0.isEmpty
            }
    }
}
