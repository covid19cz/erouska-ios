//
//  Log.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

protocol LogDelegate: class {
    func didLog(_ text: String)
}

struct Log {
    weak static var delegate: LogDelegate?

    static func log(_ text: String) {
        delegate?.didLog(text)
        print(text)
    }
}

func log(_ text: String) {
    Log.log(text)
}
