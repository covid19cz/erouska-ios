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
    typealias Section = SectionModel<String, Exposure>

    let sections: Observable<[Section]>

    let title = RemoteValues.recentExposuresUITitle

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    init() {
        let realm = AppDelegate.dependency.realm
        let exposures = realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium

        let oldTestsDate = Date(timeIntervalSince1970: 0)
        let grouped = Dictionary(grouping: exposures, by: { $0.detectedDate }).sorted(by: { $0.key > $1.key })
        sections = Observable.just(grouped.map { key, values -> Section in
            let title = key == oldTestsDate ? L10n.dataListPreviousHeader : L10n.dataListPreviousHeader + " " + dateFormatter.string(from: key)
            return .init(model: title, items: values.compactMap { $0.toExposure() })
        })
    }
}
