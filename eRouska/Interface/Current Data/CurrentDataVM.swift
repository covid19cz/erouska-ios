//
//  CurrentDataVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 25/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFunctions
import FirebaseCrashlytics
import RealmSwift
import RxSwift
import Reachability

final class CurrentDataVM {

    // MARK: - Dependencies

    typealias Dependencies = HasRealm & HasFunctions

    private let dependencies: Dependencies

    // MARK: -

    var measuresURL: URL? {
        URL(string: RemoteValues.currentMeasuresUrl)
    }

    var sections: [Section] = [] {
        didSet {
            needToUpdateView.onNext(())
        }
    }
    var footer: String? {
        didSet {
            needToUpdateView.onNext(())
        }
    }
    let needToUpdateView: BehaviorSubject<Void>
    let observableErrors: BehaviorSubject<Error?>

    private var currentData: CurrentDataRealm?

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.serverDateFormatter)
        return decoder
    }()

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        needToUpdateView = BehaviorSubject<Void>(value: ())
        observableErrors = BehaviorSubject<Error?>(value: nil)

        currentData = dependencies.realm.objects(CurrentDataRealm.self).last
        sections = sections(from: currentData)

        if currentData == nil {
            let currentData = CurrentDataRealm()
            try? dependencies.realm.write {
                dependencies.realm.add(currentData)
            }
            self.currentData = currentData
        }
    }

    func fetchCurrentDataIfNeeded() {
        // Don't fetch when internet connection is not available
        guard let connection = try? Reachability().connection, connection != .unavailable else {
            return
        }

        let dispatchGroup = DispatchGroup()
        fetchCurrentData(in: dispatchGroup)
        fetchAppCurrentData(in: dispatchGroup)

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            self.sections = self.sections(from: self.currentData)
            self.observableErrors.onNext(nil)

            AppSettings.currentDataLastFetchDate = Date()
        }
    }

}

extension CurrentDataVM {

     struct Section {
         let header: String?
         let selectableItems: Bool
         let items: [Item]
     }

     struct Item {
         let iconAsset: ImageAsset
         let title: String
         let subtitle: String?

        init(iconAsset: ImageAsset, title: String, subtitle: String? = nil) {
            self.iconAsset = iconAsset
            self.title = title
            self.subtitle = subtitle
        }
     }
}

private extension CurrentDataVM {

    struct AppCurrentJsonData: Decodable {

        let data: AppCurrentData

    }

    func fetchCurrentData(in dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()

        Auth.auth().currentUser?.getIDToken(completion: { token, error in
            if let token = token {
                let data = ["idToken": token]
                self.dependencies.functions.httpsCallable("GetCovidData").call(data) { [weak self] result, error in
                    guard let self = self else { return }
                    if let data = result?.data as? [String: Any] {
                        try? self.dependencies.realm.write {
                            self.currentData?.update(with: CovidCurrentData(with: data))
                        }
                    } else if let error = error {
                        self.observableErrors.onNext(error)
                    }
                    dispatchGroup.leave()
                }
            } else if let error = error {
                Crashlytics.crashlytics().record(error: error)
                self.observableErrors.onNext(error)
                dispatchGroup.leave()
            }
        })
    }

    func fetchAppCurrentData(in dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()

        dependencies.functions.httpsCallable("DownloadMetrics").call([:]) { [weak self] result, error in
            guard let self = self else { return }

            if let data = result?.data as? [String: Any] {
                try? self.dependencies.realm.write {
                    self.currentData?.update(with: AppCurrentData(with: data))
                }
            } else if let error = error {
                Crashlytics.crashlytics().record(error: error)
                self.observableErrors.onNext(error)
            }
            dispatchGroup.leave()
        }
    }

    func sections(from currentData: CurrentDataRealm?) -> [Section] {
        guard let data = currentData else { return [] }

        let appData = (data.appDate ?? Date()).addingTimeInterval(-24 * 60 * 60)
        let appDateSubtitle = DateFormatter.baseDateFormatter.string(from: appData)

        return [
            Section(header: L10n.currentDataMeasuresHeader, selectableItems: true, items: [
                Item(
                    iconAsset: Asset.CurrentData.measures,
                    title: L10n.currentDataMeasures
                ),
            ]),
            Section(header: L10n.currentDataItemHeader, selectableItems: false, items: [
                Item(
                    iconAsset: Asset.CurrentData.testsPCR,
                    title: L10n.currentDataItemTestsPcr(formattedValue(data.pcrTestsTotal)),
                    subtitle: L10n.currentDataAppFrom(
                        formattedValue(data.pcrTestsIncrease, showSign: true),
                        DateFormatter.baseDateFormatter.string(from: data.pcrTestsIncreaseDate ?? Date())
                    )
                ),
                Item(
                    iconAsset: Asset.CurrentData.testsAntigen,
                    title: L10n.currentDataItemTestsAntigen(formattedValue(data.antigenTestsTotal)),
                    subtitle: L10n.currentDataAppFrom(
                        formattedValue(data.antigenTestsIncrease, showSign: true),
                        DateFormatter.baseDateFormatter.string(from: data.antigenTestsIncreaseDate ?? Date())
                    )
                ),
                Item(
                    iconAsset: Asset.CurrentData.covid,
                    title: L10n.currentDataItemConfirmed(formattedValue(data.confirmedCasesTotal)),
                    subtitle: L10n.currentDataAppFrom(
                        formattedValue(data.confirmedCasesIncrease, showSign: true),
                        DateFormatter.baseDateFormatter.string(from: data.confirmedCasesIncreaseDate ?? Date())
                    )
                ),
                Item(
                    iconAsset: Asset.CurrentData.active,
                    title: L10n.currentDataItemActive(formattedValue(data.activeCasesTotal))
                ),
                Item(
                    iconAsset: Asset.CurrentData.healthy,
                    title: L10n.currentDataItemHealthy(formattedValue(data.curedTotal))
                ),
                Item(
                    iconAsset: Asset.CurrentData.death,
                    title: L10n.currentDataItemDeaths(formattedValue(data.deceasedTotal))
                ),
                Item(
                    iconAsset: Asset.CurrentData.hospital,
                    title: L10n.currentDataItemHospitalized(formattedValue(data.currentlyHospitalizedTotal))
                )
            ]),
            Section(header: L10n.currentDataAppHeader, selectableItems: false, items: [
                Item(
                    iconAsset: Asset.CurrentData.activations,
                    title: L10n.currentDataAppActivations(formattedValue(data.activationsTotal)),
                    subtitle: L10n.currentDataAppFrom(formattedValue(data.activationsYesterday, showSign: true), appDateSubtitle)
                ),
                Item(
                    iconAsset: Asset.CurrentData.sentData,
                    title: L10n.currentDataAppKeyPublishers(formattedValue(data.keyPublishersTotal)),
                    subtitle: L10n.currentDataAppFrom(formattedValue(data.keyPublishersYesterday, showSign: true), appDateSubtitle)
                ),
                Item(
                    iconAsset: Asset.CurrentData.notifications,
                    title: L10n.currentDataAppNotifications(formattedValue(data.notificationsTotal)),
                    subtitle: L10n.currentDataAppFrom(formattedValue(data.notificationsYesterday, showSign: true), appDateSubtitle)
                )
            ])
        ]
    }

    func formattedValue(_ value: Int, showSign: Bool = false) -> String {
        guard let formattedValue = numberFormatter.string(for: value) else { return "" }
        return showSign && value > 0 ? "+" + formattedValue : formattedValue
    }

}
