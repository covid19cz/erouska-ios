//
//  VerificationEntities.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation


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
        case testType = "TestType"
        case symptomDate = "SymptomDate"
    }

}

struct VerificationCode: Decodable {

    let verificationCode: String?
    let expiresAt: Date?
    let error: String?

    private enum CodingKeys: String, CodingKey {
        case verificationCode = "VerificationCode"
        case expiresAt = "ExpiresAt"
        case error = "Error"
    }

}

struct VerificationTokenRequst: Encodable {

    let code: String

}

struct VerificationToken: Decodable {

    let testType: VerificatioTestType?
    let symptomDate: String?
    let verificationToken: String?
    let error: String?

    private enum CodingKeys: String, CodingKey {
        case testType = "TestType"
        case symptomDate = "SymptomDate"
        case verificationToken = "VerificationToken"
        case error = "Error"
    }

}

struct VerificationCertificateRequest: Encodable {

    let verificationToken: String
    let hmacKey: String

    private enum CodingKeys: String, CodingKey {
        case verificationToken = "VerificationToken"
        case hmacKey = "ekeyhmac"
    }

}

struct VerificationCertificate: Decodable {

    let certificate: Date?
    let error: String?

    private enum CodingKeys: String, CodingKey {
        case certificate = "Certificate"
        case error = "Error"
    }

}
