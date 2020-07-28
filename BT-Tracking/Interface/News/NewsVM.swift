//
//  NewsVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 28/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct NewsVM {

    let title = "news_title"

    let continueButton = "news_button_continue"

    let closeButton = "news_button_close"

    let newsPages: [NewsPageVM] = [
        NewsPageVM(
            imageName: "News_ToTheWorld",
            headline: "news_to_the_world_title",
            body: "news_to_the_world_body"
        ),
        NewsPageVM(
            imageName: "News_ExposureNotification",
            headline: "news_exposure_notification_title",
            body: "news_exposure_notification_body"
        ),
        NewsPageVM(
            imageName: "News_NoPhoneNumber",
            headline: "news_no_phone_number_title",
            body: "news_no_phone_number_body"
        ),
        NewsPageVM(
            imageName: "News_AlwaysActive",
            headline: "news_always_active_title",
            body: "news_always_active_body"
        ),
        NewsPageVM(
            imageName: "News_Privacy",
            headline: "news_privacy_title",
            body: "news_privacy_body"
        )
    ]
}
