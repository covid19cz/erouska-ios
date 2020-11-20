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

    static var exposures: Results<ExposureRealm> {
        let realm = AppDelegate.dependency.realm
        return realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")
    }

    static var last: Exposure? {
        let exposures = self.exposures
        let showForDays = RemoteValues.serverConfiguration.showExposureForDays
        let showForDate = Calendar.current.date(byAdding: .day, value: -showForDays, to: Date()) ?? Date()

        return exposures.last(where: { $0.date > showForDate })?.toExposure()
    }

    static func lastObservable() throws -> Observable<Exposure?> {
        let exposures = self.exposures
        let showForDays = RemoteValues.serverConfiguration.showExposureForDays
        let showForDate = Calendar.current.date(byAdding: .day, value: -showForDays, to: Date()) ?? Date()

        return Observable.collection(from: exposures).map {
            $0.last(where: { $0.date > showForDate })?.toExposure()
        }
    }

    static func add(_ exposures: [Exposure], detectionDate: Date) throws {
        guard !exposures.isEmpty else { return }

        AppSettings.lastExposureWarningDate = Date()

        let realm = AppDelegate.dependency.realm
        try realm.write {
            exposures.sorted { $0.date < $1.date }.forEach { realm.add(ExposureRealm($0, detectedDate: detectionDate)) }
        }
    }

    static func cleanup() {
        let realm = AppDelegate.dependency.realm
        try? realm.write {
            exposures.forEach {
                if $0.date.addingTimeInterval(14 * 24 * 60 * 60) < Date() {
                    realm.delete($0)
                }
            }
        }
    }

}
