//
//  RiskyEncountersListVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 11/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

protocol RiskyEncountersListVM {
    var title: String { get }
    var headline: String { get }
    var items: [AsyncImageTitleViewModel] { get }
}

struct AsyncImageTitleViewModel {
    let imageUrl: URL
    let title: String
}
