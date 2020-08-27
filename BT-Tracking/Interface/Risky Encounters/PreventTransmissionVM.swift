//
//  PreventTransmissionVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 11/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct PreventTransmissionVM: RiskyEncountersListVM {
    let localizedTitle = RemoteValues.spreadPreventionUITitle
    var content: RiskyEncountersListContent? = RemoteValues.preventionContent
}
