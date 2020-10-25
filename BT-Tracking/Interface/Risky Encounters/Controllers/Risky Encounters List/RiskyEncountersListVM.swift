//
//  RiskyEncountersListVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 11/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

protocol RiskyEncountersListVM {
    var localizedTitle: String { get }
    var content: RiskyEncountersListContent? { get }
}

struct RiskyEncountersListContent {
    let headline: String?
    let items: [AsyncImageTitleViewModel]
    let footer: String?
}

struct AsyncImageTitleViewModel {
    let imageUrl: URL
    let title: String
}

struct RiskyEncountersListRemoteContent: Decodable {
    let title: String?
    let items: [Item]

    struct Item: Decodable {
        let iconUrl: String
        let label: String
    }
}
