//
//  ExposureDetections.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 15/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

final class ExposureList {

    static func lastObservable() throws -> Observable<Exposure?> {
        let realm = AppDelegate.dependency.realm
        let exposures = realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")

        let showForDays = RemoteValues.serverConfiguration.showExposureForDays
        let showForDate = Calendar.current.date(byAdding: .day, value: -showForDays, to: Date()) ?? Date()

        return Observable.collection(from: exposures).map {
            $0.last(where: { $0.date > showForDate })?.toExposure()
        }
    }

    static func add(_ exposures: [Exposure], detectionDate: Date) throws {
        guard !exposures.isEmpty else { return }

        var sorted = exposures
        sorted.sort { $0.date < $1.date }

        let realm = AppDelegate.dependency.realm
        try realm.write {
            sorted.forEach { realm.add(ExposureRealm($0, detectedDate: detectionDate)) }
        }
    }

}
