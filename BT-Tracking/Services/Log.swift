//
//  Log.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 16/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

func log(_ text: String) {
    FileLogger.shared.writeLog(text)
}
