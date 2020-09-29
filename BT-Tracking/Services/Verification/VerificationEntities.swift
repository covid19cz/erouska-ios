//
//  VerificationEntities.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation


enum VerificationError: Error {
    case noData
    case responseError(String)
}

enum VerificationTestType: String, Codable {
    case likely
    case confirmed
    case negative
}

struct VerificationCodeRequest: Encodable {

    let testType: VerificationTestType

    /// YYYY-MM-DD
    let symptomDate: String

    private enum CodingKeys: String, CodingKey {
        case testType = "testtype"
        case symptomDate
    }

}

struct VerificationCode: Decodable {

    let code: String?
    let expiresAt: Date?
    let error: String?

}

struct VerificationTokenRequest: Encodable {

    let code: String

}

struct VerificationToken: Decodable {

    let testType: VerificationTestType?
    let symptomDate: String?
    let token: String?
    let error: String?

    private enum CodingKeys: String, CodingKey {
        case testType = "testtype"
        case symptomDate
        case token = "token"
        case error
    }

}

struct VerificationCertificateRequest: Encodable {

    let token: String
    let hmacKey: String

    private enum CodingKeys: String, CodingKey {
        case token = "token"
        case hmacKey = "ekeyhmac"
    }

}

struct VerificationCertificate: Decodable {

    let certificate: String?
    let error: String?

}
