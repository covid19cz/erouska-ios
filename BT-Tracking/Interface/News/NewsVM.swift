//
//  NewsVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 28/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct NewsVM {

    let newsPages: [NewsPageVM] = [
        NewsPageVM(
            imageAsset: Asset.newsToTheWorld,
            headline: .news_to_the_world_title,
            body: .news_to_the_world_body
        ),
        NewsPageVM(
            imageAsset: Asset.newsExposureNotification,
            headline: .news_exposure_notification_title,
            body: .news_exposure_notification_body
        ),
        NewsPageVM(
            imageAsset: Asset.newsNoPhoneNumber,
            headline: .news_no_phone_number_title,
            body: .news_no_phone_number_body
        ),
        NewsPageVM(
            imageAsset: Asset.newsAlwaysActive,
            headline: .news_always_active_title,
            body: .news_always_active_body
        ),
        NewsPageVM(
            imageAsset: Asset.newsPrivacy,
            headline: .news_privacy_title,
            body: .news_privacy_body,
            bodyLinkTitle: .news_privacy_body_link,
            bodyLink: RemoteValues.conditionsOfUseUrl
        )
    ]
}
