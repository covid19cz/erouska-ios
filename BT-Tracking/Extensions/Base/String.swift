//
//  String.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 06/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

extension String {
    func chunkFormatted(withChunkSize chunkSize: Int = 4, withSeparator separator: Character = " ") -> String {
        filter { $0 != separator }
            .chunk(n: chunkSize)
            .map { String($0) }
            .joined(separator: String(separator))
    }

    func removingSpaces() -> String {
        replacingOccurrences(of: " ", with: "")
    }
}
