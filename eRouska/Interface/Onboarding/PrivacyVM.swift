//
//  PrivacyVM.swift
//  eRouska
//
//  Created by Naim Ashhab on 23/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import FirebaseFunctions

struct PrivacyVM {

    var bodyLink: String {
        RemoteValues.conditionsOfUseUrl
    }

}
