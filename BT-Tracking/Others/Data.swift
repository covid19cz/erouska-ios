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

extension String {
    var hexData: Data? {
        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }

        let utf16 = self.utf16
        guard let data = NSMutableData(capacity: utf16.count / 2) else {
            return nil
        }

        var i = utf16.startIndex
        while i != utf16.endIndex {
            guard
                let hi = decodeNibble(u: utf16[i]),
                let lo = decodeNibble(u: utf16[index(i, offsetBy: 1, limitedBy: utf16.endIndex)!])
            else {
                return nil
            }
            var value = hi << 4 + lo
            data.append(&value, length: 1)
            i = index(i, offsetBy: 2, limitedBy: utf16.endIndex)!
        }
        return data as Data
    }
}
