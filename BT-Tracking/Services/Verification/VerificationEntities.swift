//
//  VerificationEntities.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

enum VerificationTestType: String, Codable {
    case likely
    case confirmed
    case negative
}

struct VerificationTokenRequest: Encodable {

    let code: String

}

struct VerificationToken: Decodable {

    enum ErrorCode: String, Codable {
        /// Client sent an request the sever cannot parse.
        case unparsableRequest = "unparsable_request"
        /// Code invalid or used, user may need to obtain a new code.
        case codeInvalid = "code_invalid"
        /// Code has expired, user may need to obtain a new code.
        case codeExpired = "code_expired"
        /// The server has no record of that code.
        case codeNotFound = "code_not_found"
        /// The client sent an accept of an unrecognized test type.
        case invalidTestType = "invalid_test_type"
        /// The realm requires either a test or symptom date, but none was provided.
        case missingDate = "missing_date"
        /// The code may be valid, but represents a test type the client cannot process. User may need to upgrade software.
        case unsupportedTestType = "unsupported_test_type"
        /// Internal processing error, may be successful on retry.
        case internalError = "500"
    }

    let testType: VerificationTestType?
    let symptomDate: String?
    let token: String?
    let error: String?
    let errorCode: ErrorCode?

    private enum CodingKeys: String, CodingKey {
        case testType = "testtype"
        case symptomDate, token, error, errorCode
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

    enum ErrorCode: String, Codable {
        /// The provided token is invalid, or already used to generate a certificate.
        case tokenInvalid = "token_invalid"
        /// Code invalid or used, user may need to obtain a new code.
        case tokenExpired = "token_expired"
        /// The ekeyhmac field, when base64 decoded is not the right size (32 bytes).
        case hmacInvalid = "hmac_invalid"
        /// Internal processing error, may be successful on retry.
        case internalError = "500"
    }

    let certificate: String?
    let error: String?
    let errorCode: ErrorCode?

}

enum VerificationGeneralErrorCode: Int, Decodable {
    /// The client made a bad/invalid request. Search the JSON response body for the "errors" key. The body may be empty.
    case invalidRequest = 400
    /// The client is unauthorized. This could be an invalid API key or revoked permissions. This usually has no "errors" key.
    case unauthorizedRequest = 401
    /// The client made a request to an invalid URL (routing error). Do not retry.
    case invalidRequestURL = 404
    /// The client used the wrong HTTP verb. Do not retry.
    case wrongHTTPVerb = 405
    /// The client requested a precondition that cannot be satisfied.
    case invalidPrecodintion = 412
    /// The client is rate limited. Check the X-Retry-After header to determine when to retry the request.
    /// Clients can also monitor the X-RateLimit-Remaining header that's returned with all responses to determine their rate limit and rate limit expiration.
    case rateLimitReached = 429
    /// Internal server error. Clients should retry with a reasonable backoff algorithm and maximum cap.
    case internalError = 500
    /// Unknown reason
    case unknown = 999

    init(response: HTTPURLResponse?) {
        let value = Self(rawValue: response?.statusCode ?? 999)
        self = value ?? .unknown
    }
}

enum VerificationError: Error {
    case noData
    case tokenError(VerificationGeneralErrorCode, VerificationToken.ErrorCode)
    case certificateError(VerificationGeneralErrorCode, VerificationCertificate.ErrorCode)
    case generalError(VerificationGeneralErrorCode, String)
}
