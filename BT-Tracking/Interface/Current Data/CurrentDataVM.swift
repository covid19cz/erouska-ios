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

    struct Section {
        let header: String?
        let selectableItems: Bool
        let items: [Item]
    }

    struct Item {
        let iconName: String
        let title: String
        let subtitle: String?
    }

    let tabTitle = "data_list_title"
    let tabIcon = UIImage(named: "MyData")

    let measuresURL = URL(string: "https://koronavirus.mzcr.cz/aktualni-opatreni/")! // TODO: Make remote configurable

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

    private var currentData: CurrentDataRealm? {
        didSet {
            sections = sections(from: currentData)
        }
    }

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
        needToUpdateView = BehaviorSubject<Void>.init(value: ())

        let realm = try! Realm()
        currentData = realm.objects(CurrentDataRealm.self).first
        sections = sections(from: currentData)

        updateFooter()
    }

    func fetchCurrentDataIfNeeded() {
        if let lastFetchedDate = AppSettings.currentDataLastFetchDate {
            var components = DateComponents()
            components.hour = 3
            if Calendar.current.date(byAdding: components, to: lastFetchedDate)! > Date() { return }
        }

        AppDelegate.dependency.functions.httpsCallable("GetCovidData").call(["date": "20200824"]) { [weak self] result, error in
            if let result = result?.data as? [String: Any] {
                let data = CurrentDataRealm(
                    testsTotal: result["testsTotal"] as! Int,
                    testsIncrease: result["testsIncrease"] as! Int,
                    confirmedCasesTotal: result["confirmedCasesTotal"] as! Int,
                    confirmedCasesIncrease: result["confirmedCasesIncrease"] as! Int,
                    activeCasesTotal: result["activeCasesTotal"] as! Int,
                    activeCasesIncrease: result["activeCasesIncrease"] as! Int,
                    curedTotal: result["curedTotal"] as! Int,
                    curedIncrease: result["curedIncrease"] as! Int,
                    deceasedTotal: result["deceasedTotal"] as! Int,
                    deceasedIncrease: result["deceasedIncrease"] as! Int,
                    currentlyHospitalizedTotal: result["currentlyHospitalizedTotal"] as! Int,
                    currentlyHospitalizedIncrease: result["currentlyHospitalizedIncrease"] as! Int
                )
                self?.saveFetchedData(data)
                self?.currentData = data
            } else {
                dump(error) // TODO:
            }
        }
    }

    private func saveFetchedData(_ currentDate: CurrentDataRealm) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CurrentDataRealm.self))
            realm.add(currentDate)
        }
        AppSettings.currentDataLastFetchDate = Date()
        updateFooter()
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
                Item(iconName: "CurrentData/Measures", title: Localizable("current_data_measures"), subtitle: nil),
            ]),
            Section(header: Localizable("current_data_item_header"), selectableItems: false, items: [
                Item(
                    iconName: "CurrentData/Tests",
                    title: titleValue(data.testsTotal, withKey: "current_data_item_tests"),
                    subtitle: titleValue(data.testsIncrease, withKey: "current_data_item_yesterday")
                ),
                Item(
                    iconName: "CurrentData/Covid",
                    title: titleValue(data.confirmedCasesTotal, withKey: "current_data_item_confirmed"),
                    subtitle: titleValue(data.confirmedCasesIncrease, withKey: "current_data_item_yesterday")
                ),
                Item(
                    iconName: "CurrentData/Active",
                    title: titleValue(data.activeCasesTotal, withKey: "current_data_item_active"),
                    subtitle: titleValue(data.activeCasesIncrease, withKey: "current_data_item_yesterday")
                ),
                Item(
                    iconName: "CurrentData/Healthy",
                    title: titleValue(data.curedTotal, withKey: "current_data_item_healthy"),
                    subtitle: titleValue(data.curedIncrease, withKey: "current_data_item_yesterday")
                ),
                Item(
                    iconName: "CurrentData/Death",
                    title: titleValue(data.deceasedTotal, withKey: "current_data_item_deaths"),
                    subtitle: titleValue(data.deceasedIncrease, withKey: "current_data_item_yesterday")
                ),
                Item(
                    iconName: "CurrentData/Hospital",
                    title: titleValue(data.currentlyHospitalizedTotal, withKey: "current_data_item_hospitalized"),
                    subtitle: titleValue(data.currentlyHospitalizedIncrease, withKey: "current_data_item_yesterday")
                ),
            ])
        ]
    }

    private func titleValue(_ value: Int, withKey key: String) -> String {
        guard let formattedValue = numberFormatter.string(for: value) else { return "" }
        return String(format: Localizable(key), formattedValue)
    }
}
