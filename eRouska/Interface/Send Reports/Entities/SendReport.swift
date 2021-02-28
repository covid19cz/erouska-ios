//
//  Verification.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 28.02.2021.
//

import Foundation

struct SendReport: Codable {

    let verificationCode: String
    let verificationToken: String
    let verificationTokenDate: Date

    var symptoms: Bool = false
    var symptomsDate = Date()
    var traveler: Bool = false
    var shareToEFGS: Bool = false

}
