//
//  CurrentDataVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 25/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class CurrentDataVM {
    let tabTitle = "data_list_title"
    let tabIcon = UIImage(named: "MyData")

    let measuresURL = URL(string: "https://koronavirus.mzcr.cz/aktualni-opatreni/")! // TODO: Make remote configurable

    let footer = String(format: Localizable("current_data_footer"), "14. 5. 2020") // TODO:

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

    let sections: [Section] = [
        Section(header: nil, selectableItems: true, items: [
            Item(iconName: "CurrentData/Measures", title: Localizable("current_data_measures"), subtitle: nil),
        ]),
        Section(header: Localizable("current_data_item_header"), selectableItems: false, items: [
            Item(iconName: "CurrentData/Tests",     title: titleValue(100, withKey: "current_data_item_tests"),         subtitle: titleValue(100, withKey: "current_data_item_yesterday")),
            Item(iconName: "CurrentData/Covid",     title: titleValue(100, withKey: "current_data_item_confirmed"),     subtitle: titleValue(100, withKey: "current_data_item_yesterday")),
            Item(iconName: "CurrentData/Active",    title: titleValue(100, withKey: "current_data_item_active"),        subtitle: titleValue(100, withKey: "current_data_item_yesterday")),
            Item(iconName: "CurrentData/Healthy",   title: titleValue(100, withKey: "current_data_item_healthy"),       subtitle: titleValue(100, withKey: "current_data_item_yesterday")),
            Item(iconName: "CurrentData/Death",     title: titleValue(100, withKey: "current_data_item_deaths"),        subtitle: titleValue(100, withKey: "current_data_item_yesterday")),
            Item(iconName: "CurrentData/Hospital",  title: titleValue(100, withKey: "current_data_item_hospitalized"),  subtitle: titleValue(100, withKey: "current_data_item_yesterday")),
        ])
    ]
}

private func titleValue(_ value: Int, withKey key: String) -> String {
    return String(format: Localizable(key), value)
}
