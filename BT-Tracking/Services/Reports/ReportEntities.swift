//
//  SendReport.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 04/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct Report: Encodable {

    let temporaryExposureKeys: [ExposureDiagnosisKey]
    let regions: [String]
    let appPackageName: String
    let verificationPayload: String?
    let hmackey: String
    let symptomOnsetInterval: Int
    let revisionToken: String?
    let padding: String?
    let platform: String

    private enum CodingKeys: String, CodingKey {
        case appPackageName = "healthAuthorityID"
        case temporaryExposureKeys
        case revisionToken
        case padding
    }

}

struct ReportResult: Decodable {

    let revisionToken: String?
    let insertedExposures: Int?

}
