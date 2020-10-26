//
//  CurrentDataVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 25/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseFunctions
import RealmSwift
import RxSwift
import Reachability

final class CurrentDataVM {

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

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()

    init() {
        needToUpdateView = BehaviorSubject<Void>(value: ())
        observableErrors = BehaviorSubject<Error?>(value: nil)

        let realm = AppDelegate.dependency.realm
        currentData = realm.objects(CurrentDataRealm.self).last
        sections = sections(from: currentData)

        if currentData == nil {
            let currentData = CurrentDataRealm()
            try? realm.write {
                realm.add(currentData)
            }
            self.currentData = currentData
        }

        updateFooter()
    }

    func fetchCurrentDataIfNeeded() {
        // Don't fetch when internet connection is not available
        guard let connection = try? Reachability().connection, connection != .unavailable else {
            return
        }

        /*if let lastFetchedDate = AppSettings.currentDataLastFetchDate {
            var components = DateComponents()
            components.hour = 3
            if Calendar.current.date(byAdding: components, to: lastFetchedDate)! > Date() { return }
        }*/

        let data = ["idToken": KeychainService.token]
        AppDelegate.dependency.functions.httpsCallable("GetCovidData").call(data) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result?.data as? [String: Any] {
                let realm = AppDelegate.dependency.realm
                try? realm.write {
                    self.currentData?.update(with: result)
                }

                DispatchQueue.main.async {
                    AppSettings.currentDataLastFetchDate = Date()

                    self.sections = self.sections(from: self.currentData)
                    self.updateFooter()
                    self.observableErrors.onNext(nil)
                }
            } else if let error = error {
                self.observableErrors.onNext(error)
            }
        }
    }

    private func updateFooter() {
        if let lastFetchedDate = AppSettings.currentDataLastFetchDate {
            footer = L10n.currentDataFooter(dateFormatter.string(from: lastFetchedDate))
        }
    }

    private func sections(from currentData: CurrentDataRealm?) -> [Section] {
        guard let data = currentData else { return [] }
        return [
            Section(header: nil, selectableItems: true, items: [
                Item(
                    iconAsset: Asset.CurrentData.measures,
                    title: L10n.currentDataMeasures
                ),
            ]),
            Section(header: L10n.currentDataItemHeader, selectableItems: false, items: [
                Item(
                    iconAsset: Asset.CurrentData.tests,
                    title: L10n.currentDataItemTests(formattedValue(data.testsTotal)),
                    subtitle: L10n.currentDataItemYesterday(formattedValue(data.testsIncrease, showSign: true))
                ),
                Item(
                    iconAsset: Asset.CurrentData.covid,
                    title: L10n.currentDataItemConfirmed(formattedValue(data.confirmedCasesTotal)),
                    subtitle: L10n.currentDataItemYesterday(formattedValue(data.confirmedCasesIncrease, showSign: true))
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
            ])
        ]
    }

    private func formattedValue(_ value: Int, showSign: Bool = false) -> String {
        guard let formattedValue = numberFormatter.string(for: value) else { return "" }
        return showSign && value > 0 ? "+" + formattedValue : formattedValue
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
