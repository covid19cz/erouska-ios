//
//  RiskyEncounterHelpVM.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 25/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct RiskyEncounterHelpVM: RiskyEncountersListVM {
    let localizedTitle = L10n.help
    var content: RiskyEncountersListContent? = RemoteValues.exposureHelpContent
}
