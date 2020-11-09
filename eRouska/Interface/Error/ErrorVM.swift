//
//  ErrorVM.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 18/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct ErrorVM {
    let headline: String
    let text: String
    let actionTitle: String
    let action: Action

    enum Action {
        case close
        case closeAndCustom(CallbackVoid)
    }

    init(headline: String, text: String, actionTitle: String, action: @escaping CallbackVoid) {
        self.init(headline: headline, text: text, actionTitle: actionTitle, action: .closeAndCustom(action))
    }

    init(headline: String, text: String, actionTitle: String, action: Action) {
        self.headline = headline
        self.text = text
        self.actionTitle = actionTitle
        self.action = action
    }
}

extension ErrorVM {

    static let unknown = ErrorVM(
        headline: L10n.errorUnknownHeadline,
        text: L10n.errorUnknownText,
        actionTitle: L10n.errorUnknownTitleAction,
        action: .close
    )
}
