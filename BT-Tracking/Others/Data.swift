//
//  Data.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 22/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

// https://stackoverflow.com/questions/39075043/how-to-convert-data-to-hex-string-in-swift
extension Data {

    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
}
