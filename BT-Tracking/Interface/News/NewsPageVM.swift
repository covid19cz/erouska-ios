//
//  NewsPageVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 28/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct NewsPageVM {
    let imageAsset: ImageAsset
    let headline: Localization
    let body: Localization
    let bodyLinkTitle: Localization?
    let bodyLink: String?

    init(imageAsset: ImageAsset, headline: Localization, body: Localization, bodyLinkTitle: Localization? = nil, bodyLink: String? = nil) {
        self.imageAsset = imageAsset
        self.headline = headline
        self.body = body
        self.bodyLinkTitle = bodyLinkTitle
        self.bodyLink = bodyLink
    }
}
