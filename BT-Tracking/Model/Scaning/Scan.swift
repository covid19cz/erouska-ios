//
//  Scan.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct Scan {
    let id = UUID().uuidString
    let identifier: String
    let name: String
    let date: Date
    let rssi: Int
}
