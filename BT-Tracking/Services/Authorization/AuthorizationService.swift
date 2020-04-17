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
    func verifyPhoneNumber(_ phoneNumber: String, completion: (Result<String, Error>) -> Void)

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

    // TODO: finish this
    func verifyPhoneNumber(_ phoneNumber: String, completion: (Result<String, Error>) -> Void) {

//        completion(.failure(error))
    }
}

// TODO: msrutek, move elsewhere
final class TestAuthorizationService: AuthorizationService {
    var signOutCalled = 0
    var shouldReturnIsLoggedIn = true

    func signOut() throws {
        signOutCalled += 1
    }

    var isLoggedIn: Bool {
        shouldReturnIsLoggedIn
    }

    func verifyPhoneNumber(_ phoneNumber: String, completion: (Result<String, Error>) -> Void) {
    }
}
