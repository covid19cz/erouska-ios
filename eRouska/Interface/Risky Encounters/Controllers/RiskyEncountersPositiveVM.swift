//
//  RiskyEncountersPositiveVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import UIKit

struct RiskyEncountersPositiveVM {
    enum Sections {
        case encounter(Date), withSymptoms, withoutSymptoms

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
            case .encounter(let date):
                return String(format: RemoteValues.riskyEncountersTitle, DateFormatter.baseDateFormatter.string(from: date))
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

    enum Rows: Int {
        case text = 0
        case button = 1

        var identifier: String {
            switch self {
            case .button:
                return "buttonCell"
            case .text:
                return "textCell"
            }
        }
    }

    let sections: [Sections]

    let title = RemoteValues.exposureUITitle

    init() {
        let lastExposure = ExposureList.last
        sections = [Sections.encounter(lastExposure?.date ?? Date()), .withSymptoms, .withoutSymptoms]
    }
}
