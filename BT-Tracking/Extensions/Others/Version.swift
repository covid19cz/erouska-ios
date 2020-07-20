//
//  Version.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 17/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct Version {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension String.StringInterpolation {

    mutating func appendInterpolation(_ value: Version) {
        appendInterpolation(value.rawValue)
    }
}

extension Version {

    static var currentOSVersion: Version {
        return Version(UIDevice.current.systemVersion)
    }
}

extension Version: Comparable {

    static public func < (lhs: Version, rhs: Version) -> Bool {
        let values = (parseValues(lhs), parseValues(rhs))
        return values.0.count > values.1.count ?
            compare(moreValues: values.0, lessValues: values.1) == .orderedAscending :
            compare(moreValues: values.1, lessValues: values.0) == .orderedDescending
    }

    static public func == (lhs: Version, rhs: Version) -> Bool {
        let values = (parseValues(lhs), parseValues(rhs))
        return values.0.count > values.1.count ?
            compare(moreValues: values.0, lessValues: values.1) == .orderedSame :
            compare(moreValues: values.1, lessValues: values.0) == .orderedSame
    }

    static private func compare(moreValues: [Int], lessValues: [Int]) -> ComparisonResult {
        for pair in zip(moreValues, lessValues + Array(repeating: 0, count: moreValues.count - lessValues.count)) {
            if pair.0 == pair.1 { continue }
            return pair.0 < pair.1 ? .orderedAscending : .orderedDescending
        }
        return .orderedSame
    }

    static private func parseValues(_ appVersion: Version) -> [Int] {
        return appVersion.rawValue.components(separatedBy: ".").compactMap(Int.init)
    }
}
