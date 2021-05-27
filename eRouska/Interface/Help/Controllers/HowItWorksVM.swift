//
//  HowItWorksVM.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 19.02.2021.
//

import Foundation

struct HowItWorksEntry {

    let title: String?
    let body: String
    let icon: ImageAsset?

}

struct HowItWorksVM {

    var entries: [HowItWorksEntry] = [
        .init(title: nil, body: L10n.howitworksHeadline, icon: nil),
        .init(title: L10n.HowitworksEntry1.title, body: L10n.HowitworksEntry1.body, icon: Asset.hitWPhones),
        .init(title: L10n.HowitworksEntry2.title, body: L10n.HowitworksEntry2.body, icon: Asset.hitWExposure),
        .init(title: L10n.HowitworksEntry3.title, body: L10n.HowitworksEntry3.body, icon: Asset.hItWNotifications),
        .init(title: L10n.HowitworksEntry4.title, body: L10n.HowitworksEntry4.body, icon: Asset.hitWCheck),
        .init(title: L10n.HowitworksEntry5.title, body: RemoteValues.howItWorksEvalContent, icon: Asset.hitWResult),
        .init(title: L10n.HowitworksEntry6.title, body: L10n.HowitworksEntry6.body, icon: Asset.hitWDisplay)
    ]

}
