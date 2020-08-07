//
//  VerificationService.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import Alamofire

protocol VerificationServicing: class {

    typealias CodeCallback = (Result<VerificationCode, Error>) -> Void
    func requestCode(with request: VerificationCodeRequst, callback: @escaping CodeCallback)

    typealias VerifyCallback = (Result<VerificationToken, Error>) -> Void
    func verify(with code: String, callback: @escaping VerifyCallback)

    typealias CertificateCallback = (Result<VerificationCertificate, Error>) -> Void
    func requestCertificate(token: String, hmacKey: String, callback: @escaping CertificateCallback)

}

final class VerificationService: VerificationServicing {

    private let serverURL = URL(string: "https://apiserver-eyrqoibmxa-ew.a.run.app/api")!

    func requestCode(with request: VerificationCodeRequst, callback: @escaping CodeCallback) {
        AF.request(URL(string: "code", relativeTo: serverURL)!, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: VerificationCode.self) { response in
                debugPrint(response)
                switch response.result {
                case .success(let result):
                    callback(.success(result))
                case .failure(let error):
                    callback(.failure(error))
                }
        }
    }

    func verify(with code: String, callback: @escaping VerifyCallback) {
        let request = VerificationTokenRequst(code: code)
        AF.request(URL(string: "verify", relativeTo: serverURL)!, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: VerificationToken.self) { response in
                debugPrint(response)
                switch response.result {
                case .success(let result):
                    callback(.success(result))
                case .failure(let error):
                    callback(.failure(error))
                }
        }
    }

    func requestCertificate(token: String, hmacKey: String, callback: @escaping CertificateCallback) {
        let request = VerificationCertificateRequest(verificationToken: token, hmacKey: hmacKey)
        AF.request(URL(string: "certificate", relativeTo: serverURL)!, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: VerificationCertificate.self) { response in
                debugPrint(response)
                switch response.result {
                case .success(let result):
                    callback(.success(result))
                case .failure(let error):
                    callback(.failure(error))
                }
        }
    }

}
