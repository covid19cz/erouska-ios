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
}

final class DefaultAuthorizationService: AuthorizationService {
    private let auth: Auth

    func signOut() throws {
        try auth.signOut()
    }

    var isLoggedIn: Bool {
        return KeychainService.BUID != nil && KeychainService.TUIDs != nil && auth.currentUser != nil
    }

    init(auth: Auth = .auth()) {
        self.auth = auth
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
}
