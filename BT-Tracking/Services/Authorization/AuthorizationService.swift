//
//  AuthorizationService.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 17/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol AuthorizationService: AnyObject {
    func signOut() throws
    var isLoggedIn: Bool { get }
    var phoneNumber: String? { get }
    func verifyPhoneNumber(_ phoneNumber: String, completion: @escaping (Result<String, PhoneAuthenticationError>) -> Void)
    func verifyCode(_ code: String, withVerificationId verificationId: String, completion: @escaping (Result<Void, VerificationCodeError>) -> Void)
}

enum PhoneAuthenticationError: Error {
    case general
    case limitExceeded
}

enum VerificationCodeError: Error {
    case invalid
    case expired
    case general
}

final class DefaultAuthorizationService: AuthorizationService {
    private let auth: Auth
    private let phoneAuthProvider: PhoneAuthProvider

    init(
        auth: Auth = .auth(),
        phoneAuthProvider: PhoneAuthProvider = .provider()
    ) {
        self.auth = auth
        self.phoneAuthProvider = phoneAuthProvider
    }

    func signOut() throws {
        try auth.signOut()
    }

    var isLoggedIn: Bool {
        KeychainService.BUID != nil && KeychainService.TUIDs != nil && auth.currentUser != nil
    }

    var phoneNumber: String? {
        auth.currentUser?.phoneNumber?.phoneFormatted
    }

    func verifyPhoneNumber(_ phoneNumber: String, completion: @escaping (Result<String, PhoneAuthenticationError>) -> Void) {
        phoneAuthProvider.verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let verificationID = verificationID {
                completion(.success(verificationID))
            } else if let error = error as NSError? {
                log("AuthorizationService: phoneNumber verification error: \(error.localizedDescription), code: \(error.code)")
                if error.code == AuthErrorCode.tooManyRequests.rawValue {
                    completion(.failure(.limitExceeded))
                } else {
                    completion(.failure(.general))
                }
            } else {
                completion(.failure(.general))
            }
        }
    }

    func verifyCode(_ code: String, withVerificationId verificationId: String, completion: @escaping (Result<Void, VerificationCodeError>) -> Void) {
        let credential = phoneAuthProvider.credential(withVerificationID: verificationId, verificationCode: code)

        auth.signIn(with: credential) { _, error in
            if let error = error as NSError? {
                log("AuthorizationService: verifyCode error: \(error.localizedDescription), code: \(error.code)")

                switch error.code {
                case AuthErrorCode.invalidVerificationCode.rawValue:
                    completion(.failure(.invalid))
                case AuthErrorCode.sessionExpired.rawValue:
                    completion(.failure(.expired))
                default:
                    completion(.failure(.general))
                }
            } else {
                // ¯\_(ツ)_/¯
                completion(.success(()))
            }
        }
    }
}
