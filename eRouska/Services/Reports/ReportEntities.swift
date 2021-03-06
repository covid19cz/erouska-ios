//
//  ReportEntities.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 04/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import Alamofire

enum ReportError: Error {
    case noData
    case noFile
    case cancelled
    case unknown
    case alreadyRunning
    case stringEncodingFailure
    case responseError(AFError)
    case generalError(Error)
}

struct ReportIndex: Decodable {
    let country: String
    let url: String
}

struct ReportDownload {

    static var all = "ALL"

    typealias Success = [String: ReportKeys]
    typealias Failure = [String: ReportError]

    let success: Success
    let failures: Failure

    init(success: ReportDownload.Success, failures: ReportDownload.Failure) {
        self.success = success
        self.failures = failures
    }

    init(failure: ReportError) {
        self.success = [:]
        self.failures = [Self.all: failure]
    }

}

enum ReportUploadError: Error {
    case upload(String, String?)
}

struct Report: Encodable {

    /// Required and must have length >= 1 and <= 21 (`maxKeysPerPublish`)
    let temporaryExposureKeys: [ExposureDiagnosisKey]

    /// The identifier for the mobile application.
    let healthAuthority: String

    /// The Verification Certificate from a verification server.
    let verificationPayload: String?

    /// The device generated secret that is used to recalculate the HMAC value, that is present in the verification payload.
    let hmacKey: String?

    /// An interval number that aligns with the symptom onset date.
    ///  - Uses the same interval system as TEK timing.
    ///  - Will be rounded down to the start of the UTC day provided.
    ///  - Will be used to calculate the days +/- symptom onset for provided keys.
    ///  - MUST be no more than 14 days ago.
    ///  - Does not have to be within range of any of the provided keys (i.e. future key uploads)
    let symptomOnsetInterval: Int?

    /// Set to true if the TEKs in this publish set are consider to be the
    /// keys of a "traveler" who has left the home region represented by this server
    /// (or by the home health authority in case of a multi-tenant installation).
    let traveler: Bool

    /// An opaque string that must be passed in-tact from on additional
    /// publish requests from the same device, there the same TEKs may be published again.
    let revisionToken: String?

    /// Random base64 encoded data to obscure the request size. The server will not process this data in any way.
    let padding: String

    // MARK: - EFGS parameters

    let visitedCountries: [String]

    let reportType: ReportType

    let consentToFederation: Bool

    private enum CodingKeys: String, CodingKey {
        case healthAuthority = "healthAuthorityID"
        case temporaryExposureKeys
        case verificationPayload
        case hmacKey
        case symptomOnsetInterval
        case traveler
        case revisionToken
        case padding
        case visitedCountries
        case reportType
        case consentToFederation
    }

}

struct ReportResult: Decodable {

    /// The revisionToken indicates an opaque string that must be passed back if the same devices wishes to publish TEKs again.
    let revisionToken: String?
    let insertedExposures: Int?

    /// On error, the error message will contain a message from the server
    let error: String?

    /// Field will contain one of the constants defined in this file.
    /// The intent is that code can be used to show a localized error message on the device.
    let code: String?

}

enum ReportType: String, Codable {
    case unknown = "Unknown"
    case confirmedTest = "ConfirmedTest"
    case confirmedClinicalDiagnosis = "ConfirmedClinicalDiagnosis"
    case selfReport = "SelfReport"
    case recursive = "Recursive"
    case revoked = "Revoked"
}

struct ReportKeys {

    let URLs: [URL]
    let lastProcessedFileName: String?

}
