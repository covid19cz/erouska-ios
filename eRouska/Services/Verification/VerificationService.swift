//
//  VerificationService.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import Alamofire

protocol HasVerificationService {
    var verification: VerificationServicing { get }
}

protocol VerificationServicing: AnyObject {

    func updateConfiguration(_ configuration: ServerConfiguration)

    typealias VerifyCallback = (Result<String, VerificationError>) -> Void
    func verify(with code: String, callback: @escaping VerifyCallback)

    typealias CertificateCallback = (Result<String, VerificationError>) -> Void
    func requestCertificate(token: String, hmacKey: String, callback: @escaping CertificateCallback)

}

final class VerificationService: VerificationServicing {

    private var serverURL: URL
    private let headerApiKey = "X-API-Key"
    private var deviceKey: String

    init(configuration: ServerConfiguration) {
        serverURL = configuration.verificationURL
        deviceKey = configuration.verificationDeviceKey
    }

    func updateConfiguration(_ configuration: ServerConfiguration) {
        serverURL = configuration.verificationURL
        deviceKey = configuration.verificationDeviceKey
    }

    func verify(with code: String, callback: @escaping VerifyCallback) {
        var headers = HTTPHeaders()
        headers.add(HTTPHeader(name: headerApiKey, value: deviceKey))

        let request = VerificationTokenRequest(code: code)
        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "api/verify", relativeTo: serverURL)!
        AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .responseDecodable(of: VerificationToken.self) { response in
                #if DEBUG
                debugPrint(response)
                #endif

                switch response.result {
                case .success(let result):
                    if let token = result.token {
                        callback(.success(token))
                    } else if let error = result.errorCode {
                        callback(.failure(VerificationError.tokenError(VerificationGeneralErrorCode(response: response.response), error)))
                    } else if let error = result.error {
                        callback(.failure(VerificationError.generalError(VerificationGeneralErrorCode(response: response.response), error)))
                    } else {
                        callback(.failure(VerificationError.noData))
                    }
                case .failure(let error):
                    callback(.failure(VerificationError.generalError(VerificationGeneralErrorCode(response: response.response), error.localizedDescription)))
                }
            }
    }

    func requestCertificate(token: String, hmacKey: String, callback: @escaping CertificateCallback) {
        var headers = HTTPHeaders()
        headers.add(HTTPHeader(name: headerApiKey, value: deviceKey))

        let request = VerificationCertificateRequest(token: token, hmacKey: hmacKey)
        // swiftlint:disable:next force_unwrapping
        let url = URL(string: "api/certificate", relativeTo: serverURL)!
        AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .responseDecodable(of: VerificationCertificate.self) { response in
                #if DEBUG
                debugPrint(response)
                #endif

                switch response.result {
                case .success(let result):
                    if let certificate = result.certificate {
                        callback(.success(certificate))
                    } else if let error = result.errorCode {
                        callback(.failure(VerificationError.certificateError(VerificationGeneralErrorCode(response: response.response), error)))
                    } else if let error = result.error {
                        callback(.failure(VerificationError.generalError(VerificationGeneralErrorCode(response: response.response), error)))
                    } else {
                        callback(.failure(VerificationError.noData))
                    }
                case .failure(let error):
                    callback(.failure(VerificationError.generalError(VerificationGeneralErrorCode(response: response.response), error.localizedDescription)))
                }
            }
    }

}
