//
//  FakeServer.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 23/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

// TODO: Implement after server API is ready
typealias Server = FakeServer

final class FakeServer {

    static var shared = FakeServer()

    func requesteHRID(_ callback: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            callback(.success("e123456ABC"))
        }
    }
}
