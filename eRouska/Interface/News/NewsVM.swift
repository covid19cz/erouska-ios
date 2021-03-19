//
//  NewsVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 28/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct NewsVM {

    let type: NewsType
    var newsPages: [NewsPageVM] {
        type.pages
    }

    init(type: NewsType) {
        self.type = type
    }

}

enum NewsType {

    case upgrade
    case efgs

    var pages: [NewsPageVM] {
        switch self {
        case .upgrade:
            return [
                NewsPageVM(
                    imageAsset: Asset.newsToTheWorld,
                    headline: L10n.newsToTheWorldTitle,
                    body: L10n.newsToTheWorldBody
                ),
                NewsPageVM(
                    imageAsset: Asset.newsExposureNotification,
                    headline: L10n.newsExposureNotificationTitle,
                    body: L10n.newsExposureNotificationBody
                ),
                NewsPageVM(
                    imageAsset: Asset.newsNoPhoneNumber,
                    headline: L10n.newsNoPhoneNumberTitle,
                    body: L10n.newsNoPhoneNumberBody
                ),
                NewsPageVM(
                    imageAsset: Asset.newsAlwaysActive,
                    headline: L10n.newsAlwaysActiveTitle,
                    body: L10n.newsAlwaysActiveBody
                ),
                NewsPageVM(
                    imageAsset: Asset.newsPrivacy,
                    headline: L10n.newsPrivacyTitle,
                    body: L10n.newsPrivacyBody,
                    bodyLinkTitle: L10n.newsPrivacyBodyLink,
                    bodyLink: RemoteValues.conditionsOfUseUrl
                ),
                efgsPage
            ]
        case .efgs:
            return [efgsPage]
        }
    }

    private var efgsPage: NewsPageVM {
        NewsPageVM(
            imageAsset: Asset.newsTravel,
            headline: L10n.newsTravelTitle,
            body: L10n.newsTravelBody(RemoteValues.efgsDays),
            bodyLinkTitle: L10n.newsPrivacyBodyLink,
            bodyLink: RemoteValues.conditionsOfUseUrl,
            switchTitle: L10n.newsTravelEnable,
            switchCallback: { isOn in
                AppSettings.efgsEnabled = isOn
            },
            footer: RemoteValues.efgsCountries
        )
    }

}
