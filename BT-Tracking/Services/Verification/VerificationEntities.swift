//
//  VerificationEntities.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation


enum VerificatioError: Error {
    case noData
    case responseError(String)
}

enum VerificatioTestType: String, Codable {
    case likely
    case confirmed
    case negative
}

struct VerificationCodeRequst: Encodable {

    let testType: VerificatioTestType

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

struct VerificationTokenRequst: Encodable {

    let code: String

}

struct VerificationToken: Decodable {

    let testType: VerificatioTestType?
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
