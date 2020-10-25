//
//  PreviousRiskyEncountersVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm
import RxDataSources

struct PreviousRiskyEncountersVM {

    let title = RemoteValues.recentExposuresUITitle

    typealias Section = SectionModel<String, Exposure>

    let sections: Observable<[Section]>

    init() {
        let realm = AppDelegate.dependency.realm
        let exposures = realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")

        let oldTestsDate = Date(timeIntervalSince1970: 0)
        let grouped = Dictionary(grouping: exposures, by: { $0.detectedDate }).sorted(by: { $0.key > $1.key })
        sections = Observable.just(grouped.map { key, values -> Section in
            let title: String
            if key == oldTestsDate {
                if let date = AppSettings.lastLegacyDataFetchDate {
                    title = L10n.dataListPreviousHeader + " " + DateFormatter.baseDateFormatter.string(from: date)
                } else {
                    title = L10n.dataListPreviousHeader
                }
            } else {
                title = L10n.dataListPreviousHeader + " " + DateFormatter.baseDateTimeFormatter.string(from: key)
            }
            return .init(model: title, items: values.compactMap { $0.toExposure() })
        })
    }
}
