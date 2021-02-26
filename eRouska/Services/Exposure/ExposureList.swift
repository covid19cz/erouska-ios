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

protocol HasExposureList {
    var exposureList: ExposureListing { get }
}

protocol ExposureListing {
    var exposures: Results<ExposureRealm> { get }

    var last: Exposure? { get }

    func lastObservable() throws -> Observable<Exposure?>
    func add(_ exposures: [Exposure], detectionDate: Date) throws
    func cleanup()
}

final class ExposureList: ExposureListing {

    // MARK: - Dependencies

    typealias Dependencies = HasRealm

    var dependencies: Dependencies

    // MARK: -

    var exposures: Results<ExposureRealm> {
        return dependencies.realm.objects(ExposureRealm.self).sorted(byKeyPath: "date")
    }

    var last: Exposure? {
        let exposures = self.exposures
        let showForDays = RemoteValues.serverConfiguration.showExposureForDays
        let showForDate = Calendar.current.date(byAdding: .day, value: -showForDays, to: Date()) ?? Date()

        return exposures.last(where: { $0.date > showForDate })?.toExposure()
    }

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func lastObservable() throws -> Observable<Exposure?> {
        let exposures = self.exposures
        let showForDays = RemoteValues.serverConfiguration.showExposureForDays
        let showForDate = Calendar.current.date(byAdding: .day, value: -showForDays, to: Date()) ?? Date()

        return Observable.collection(from: exposures).map {
            $0.last(where: { $0.date > showForDate })?.toExposure()
        }
    }

    func add(_ exposures: [Exposure], detectionDate: Date) throws {
        guard !exposures.isEmpty else { return }

        AppSettings.lastExposureWarningDate = Date()
        AppSettings.lastExposureWarningNotDisplayed = true

        try dependencies.realm.write {
            exposures.sorted { $0.date < $1.date }.forEach {
                if let window = $0.window {
                    dependencies.realm.add(ExposureRealm(window, detectedDate: detectionDate))
                } else {
                    dependencies.realm.add(ExposureRealm($0, detectedDate: detectionDate))
                }
            }
        }
    }

    func cleanup() {
        try? dependencies.realm.write {
            exposures.forEach {
                if $0.date.addingTimeInterval(14 * 24 * 60 * 60) < Date() {
                    dependencies.realm.delete($0)
                }
            }
        }
    }

}
