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

final class CurrentDataVM {

    let tabTitle = "data_list_title"
    let tabIcon = UIImage(named: "MyData")

    var measuresURL: URL? {
        return URL(string: RemoteValues.currentMeasuresUrl)
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
    let obervableErrors: BehaviorSubject<Error?>

    private var currentData: CurrentDataRealm?

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MM. yyyy"
        return formatter
    }()

    init() {
        needToUpdateView = BehaviorSubject<Void>(value: ())
        obervableErrors = BehaviorSubject<Error?>(value: nil)

        let realm = try! Realm()
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
        /*if let lastFetchedDate = AppSettings.currentDataLastFetchDate {
            var components = DateComponents()
            components.hour = 3
            if Calendar.current.date(byAdding: components, to: lastFetchedDate)! > Date() { return }
        }*/

        let data = ["idToken": KeychainService.token]
        AppDelegate.dependency.functions.httpsCallable("GetCovidData").call(data) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result?.data as? [String: Any] {
                let realm = try? Realm()
                try? realm?.write {
                    if let value = result["testsTotal"] as? Int { self.currentData?.testsTotal = value }
                    if let value = result["testsIncrease"] as? Int { self.currentData?.testsIncrease = value }
                    if let value = result["confirmedCasesTotal"] as? Int { self.currentData?.confirmedCasesTotal = value }
                    if let value = result["confirmedCasesIncrease"] as? Int { self.currentData?.confirmedCasesIncrease = value }
                    if let value = result["activeCasesTotal"] as? Int { self.currentData?.activeCasesTotal = value }
                    if let value = result["curedTotal"] as? Int { self.currentData?.curedTotal = value }
                    if let value = result["deceasedTotal"] as? Int { self.currentData?.deceasedTotal = value }
                    if let value = result["currentlyHospitalizedTotal"] as? Int { self.currentData?.currentlyHospitalizedTotal = value }
                }

                DispatchQueue.main.async {
                    AppSettings.currentDataLastFetchDate = Date()

                    self.sections = self.sections(from: self.currentData)
                    self.updateFooter()
                }
            } else if let error = error {
                if AppSettings.currentDataLastFetchDate == nil {
                    self.sections = self.sections(from: self.currentData)
                    self.updateFooter()

                    self.obervableErrors.onNext(error)
                }
            }
        }
    }

    private func updateFooter() {
        if let lastFetchedDate = AppSettings.currentDataLastFetchDate {
            footer = String(format: Localizable("current_data_footer"), dateFormatter.string(from: lastFetchedDate))
        }
    }

    private func sections(from currentData: CurrentDataRealm?) -> [Section] {
        guard let data = currentData else { return [] }
        return [
            Section(header: nil, selectableItems: true, items: [
                Item(iconName: "CurrentData/Measures", title: Localizable("current_data_measures")),
            ]),
            Section(header: Localizable("current_data_item_header"), selectableItems: false, items: [
                Item(
                    iconName: "CurrentData/Tests",
                    title: titleValue(data.testsTotal, withKey: "current_data_item_tests"),
                    subtitle: titleValue(data.testsIncrease, withKey: "current_data_item_yesterday", showSign: true)
                ),
                Item(
                    iconName: "CurrentData/Covid",
                    title: titleValue(data.confirmedCasesTotal, withKey: "current_data_item_confirmed"),
                    subtitle: titleValue(data.confirmedCasesIncrease, withKey: "current_data_item_yesterday", showSign: true)
                ),
                Item(
                    iconName: "CurrentData/Active",
                    title: titleValue(data.activeCasesTotal, withKey: "current_data_item_active")
                ),
                Item(
                    iconName: "CurrentData/Healthy",
                    title: titleValue(data.curedTotal, withKey: "current_data_item_healthy")
                ),
                Item(
                    iconName: "CurrentData/Death",
                    title: titleValue(data.deceasedTotal, withKey: "current_data_item_deaths")
                ),
                Item(
                    iconName: "CurrentData/Hospital",
                    title: titleValue(data.currentlyHospitalizedTotal, withKey: "current_data_item_hospitalized")
                ),
            ])
        ]
    }

    private func titleValue(_ value: Int, withKey key: String, showSign: Bool = false) -> String {
        guard let formattedValue = numberFormatter.string(for: value) else { return "" }
        return String(format: Localizable(key), showSign && value > 0 ? "+" + formattedValue : formattedValue)
    }
}

extension CurrentDataVM {

     struct Section {
         let header: String?
         let selectableItems: Bool
         let items: [Item]
     }

     struct Item {
         let iconName: String
         let title: String
         let subtitle: String?

        init(iconName: String, title: String, subtitle: String? = nil) {
            self.iconName = iconName
            self.title = title
            self.subtitle = subtitle
        }
     }
}
