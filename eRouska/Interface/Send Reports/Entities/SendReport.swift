//
//  Verification.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 28.02.2021.
//

import Foundation
import JWTDecode

struct SendReport: Codable {

    let verificationCode: String
    let verificationToken: String
    let verificationTokenDate: Date

    var symptoms: Bool = false
    var symptomsDate: Date?
    var traveler: Bool = false
    var consentToFederation: Bool = false

    var isExpired: Bool {
        guard let jwt = try? decode(jwt: verificationToken), !jwt.expired, let date = jwt.expiresAt else { return true }

        if Date() > date - 15 * 60 {
            return true
        }
        return false
    }

}
