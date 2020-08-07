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
    let healthAuthority: String
    let revisionToken: String?
    let padding: String

    private enum CodingKeys: String, CodingKey {
        case healthAuthority = "healthAuthorityID"
        case temporaryExposureKeys
        case revisionToken
        case padding
    }

}

struct ReportResult: Decodable {

    let revisionToken: String?
    let insertedExposures: Int?

}
