//
//  VerificationService.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

protocol VerificationServicing: class {

    typealias CodeCallback = (Result<VerificationCode, Error>) -> Void
    func requestCode(with request: VerificationCodeRequst, callback: @escaping CodeCallback)

    typealias VerifyCallback = (Result<VerificationToken, Error>) -> Void
    func verify(with code: String, callback: @escaping VerifyCallback)

    typealias CertificateCallback = (Result<VerificationCertificate, Error>) -> Void
    func requestCertificate(token: String, callback: @escaping CertificateCallback)

}

final class VerificationService: VerificationServicing {

    func requestCode(with request: VerificationCodeRequst, callback: @escaping CodeCallback) {

    }

    func verify(with code: String, callback: @escaping VerifyCallback) {

    }

    func requestCertificate(token: String, callback: @escaping CertificateCallback) {

    }

}
