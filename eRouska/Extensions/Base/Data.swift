//
//  Data.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 22/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

// swiftlint:disable force_unwrapping
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

    static func random(count: Int) -> Data {
        var result = Data(count: count)
        _ = result.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress!)
        }
        return result
    }

}

// swiftlint:enable force_unwrapping
