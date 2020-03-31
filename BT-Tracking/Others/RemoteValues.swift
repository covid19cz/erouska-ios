//
//  RemoteValues.swift
//  BT-Tracking
//
//  Created by Stanislav Kasprik on 29/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

enum RemoteConfigValueKey: String {
    case faqLink
}

struct RemoteValues {
    static var faqLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.faqLink)
    }
}
