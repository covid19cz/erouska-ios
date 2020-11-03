//
//  SendResultVM.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 03/11/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

enum SendResultVM {
    case standard
    case noKeys
    case error(String)

    var title: String {
        switch self {
        case .standard, .noKeys:
            return L10n.dataSendTitle
        case .error:
            return L10n.dataSendError
        }
    }

    var titleLabel: String {
        switch self {
        case .standard, .noKeys:
            return L10n.dataSendTitleLabel
        case .error:
            return L10n.dataSendTitleError
        }
    }

    var titleLabelColor: UIColor {
        switch self {
        case .standard, .noKeys:
            return Asset.appEnabled.color
        case .error:
            return Asset.alertRed.color
        }
    }

    var image: UIImage? {
        switch self {
        case .standard, .noKeys:
            return Asset.ok.image
        case .error:
            return Asset.error.image
        }
    }

    var headline: String {
        switch self {
        case .standard:
            return L10n.dataSendHeadline
        case .noKeys:
            return L10n.dataSendNokeysHeadline
        case .error(let message):
            return L10n.dataSendErrorHeadline(message)
        }
    }

    var body: String {
        switch self {
        case .standard:
            return L10n.dataSendBody
        case .noKeys:
            return L10n.dataSendNokeysBody
        case .error:
            return L10n.dataSendBody
        }
    }

    var buttonTitle: String {
        switch self {
        case .standard, .noKeys:
            return L10n.dataSendCloseButton
        case .error:
            return L10n.dataSendErrorButton
        }
    }
}
