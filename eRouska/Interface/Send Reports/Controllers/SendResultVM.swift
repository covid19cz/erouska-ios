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
    case codeInvalid
    case error(String, String?) // error: code, message

    var title: String {
        switch self {
        case .standard, .noKeys:
            return L10n.dataSendTitle
        case .codeInvalid:
            return L10n.dataListSendTitle
        case .error:
            return L10n.dataSendError
        }
    }

    var titleLabel: String {
        switch self {
        case .standard:
            return L10n.dataSendTitleLabel
        case .noKeys:
            return L10n.dataSendTitleNokeys
        case .codeInvalid:
            return L10n.dataSendInvalidCodeHeadline
        case .error:
            return L10n.dataSendTitleError
        }
    }

    var titleLabelColor: UIColor {
        switch self {
        case .standard, .noKeys:
            return Asset.appEnabled.color
        case .error, .codeInvalid:
            return Asset.alertRed.color
        }
    }

    var image: UIImage? {
        switch self {
        case .standard, .noKeys:
            return Asset.ok.image
        case .error, .codeInvalid:
            return Asset.error.image
        }
    }

    var headline: String {
        switch self {
        case .standard:
            return L10n.dataSendHeadline
        case .noKeys:
            return L10n.dataSendNokeysHeadline
        case .codeInvalid:
            return L10n.dataSendInvalidCodeBody
        case .error(let code, _):
            return L10n.dataSendErrorHeadline(code)
        }
    }

    var body: String {
        switch self {
        case .standard:
            return L10n.dataSendBody
        case .noKeys:
            return L10n.dataSendNokeysBody
        case .codeInvalid:
            return ""
        case .error:
            return L10n.dataSendErrorBody
        }
    }

    var buttonTitle: String {
        switch self {
        case .standard, .noKeys:
            return L10n.dataSendCloseButton
        case .codeInvalid:
            return L10n.dataSendTryAgainButton
        case .error:
            return L10n.dataSendErrorButton
        }
    }

    var actionTitle: String? {
        switch self {
        case .codeInvalid:
            return L10n.dataSendErrorButton
        default:
            return nil
        }
    }
}
