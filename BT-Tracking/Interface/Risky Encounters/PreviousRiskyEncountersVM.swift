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

        let grouped = Dictionary(grouping: exposures, by: { $0.detectedDate })
        sections = Observable.just(grouped.map { key, values -> Section in
            .init(model: L10n.dataListPreviousHeader + " " + dateFormatter.string(from: key), items: values.compactMap { $0.toExposure() })
        })
    }
}
