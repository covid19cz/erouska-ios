//
//  Auth.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 02/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import FirebaseAuth

extension Auth {

    static var isLoggedIn: Bool {
        return AppSettings.BUID != nil && Self.auth().currentUser != nil
    }
}

extension String {
    
    var phoneFormatted: String {
        let countryCode = self.dropLast(9)
        let phone = String(self.suffix(9))
        return countryCode + " " + phone.chunkFormatted(withChunkSize: 3)
    }
}

extension String {

    func chunkFormatted(withChunkSize chunkSize: Int = 4, withSeparator separator: Character = " ") -> String {
        return filter { $0 != separator }
            .chunk(n: chunkSize)
            .map { String($0) }
            .joined(separator: String(separator))
    }

    func removingSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}

extension Collection {
    public func chunk(n: Int) -> [SubSequence] {
        var res: [SubSequence] = []
        var i = startIndex
        var j: Index
        while i != endIndex {
            j = index(i, offsetBy: n, limitedBy: endIndex) ?? endIndex
            res.append(self[i..<j])
            i = j
        }
        return res
    }
}
