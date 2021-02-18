//
//  Logger.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 17/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

func log(_ text: String) {
    #if DEBUG
    print(text)
    #endif
}
