//
//  PreventTransmissionVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 11/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct PreventTransmissionVM: RiskyEncountersListVM {
    let title = "prevent_transmission_title"
    let headline = "prevent_transmission_headline"
    let items: [AsyncImageTitleViewModel] = RemoteValues.preventionContentJson
}
