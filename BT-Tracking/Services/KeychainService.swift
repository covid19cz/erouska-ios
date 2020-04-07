//
//  KeychainService.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 07/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import Security
import UIKit

struct KeychainService {

    static var BUID: String? {
        get {
            return stringValue(for: .BUID)
        }
        set {
            if let value = newValue {
                saveValue(with: .BUID, value: value)
            } else {
                removeValue(with: .BUID)
            }
        }
    }

    static var TUIDs: [String]? {
        get {
            let values: [String]? = arrayValue(for: .TUIDs)
            return values
        }
        set {
            if let values = newValue {
                saveArrayValue(with: .TUIDs, value: values)
            } else {
                removeValue(with: .TUIDs)
            }
            AppDelegate.shared.resetAdvertising()
        }
    }

}

private extension KeychainService {

    enum Keys: String {
        case BUID
        case TUIDs
    }

    enum SecurityKeys: String {
        case className, attributeAccount, attributeService, matchLimit, matchLimitOne, returnData, valueData, genericPassword

        var rawValue: Self.RawValue {
            let key: CFString
            switch self {
            case .className:
                key = kSecClass
            case .attributeAccount:
                key = kSecAttrAccount
            case .attributeService:
                key = kSecAttrService
            case .matchLimit:
                key = kSecMatchLimit
            case .matchLimitOne:
                key = kSecMatchLimitOne
            case .returnData:
                key = kSecReturnData
            case .valueData:
                key = kSecValueData
            case .genericPassword:
                key = kSecClassGenericPassword
            }
            return String(format: key as String)
        }

        static func dictionaryFrom(_ values: [Self: Any]) -> NSDictionary {
            return NSDictionary(
                objects: Array(values.values),
                forKeys: values.keys.map { $0.rawValue } as [NSString]
            ) as CFDictionary
        }
    }

    static func saveValue(with key: Keys, value: String) {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else { return }
        saveValue(with: key, value: data)
    }

    static func saveArrayValue<T: Encodable & Collection>(with key: Keys, value: T) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        saveValue(with: key, value: data)
    }

    static func saveValue(with key: Keys, value: Data) {
        let nativeQuery: [SecurityKeys: Any] = [
            .className: SecurityKeys.genericPassword.rawValue,
            .attributeService: key.rawValue,
            .attributeAccount: "local",
            .valueData: value as NSData
        ]
        let keychainQuery = SecurityKeys.dictionaryFrom(nativeQuery)

        SecItemDelete(keychainQuery)
        SecItemAdd(keychainQuery, nil)
    }

    static func removeValue(with key: Keys) {
        let nativeQuery: [SecurityKeys: Any] = [
            .className: SecurityKeys.genericPassword.rawValue,
            .attributeService: key.rawValue,
            .attributeAccount: "local"
        ]
        let keychainQuery = SecurityKeys.dictionaryFrom(nativeQuery)

        SecItemDelete(keychainQuery)
    }

    static func stringValue(for key: Keys) -> String? {
        guard let data = dataValue(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func arrayValue<T: Decodable & Collection>(for key: Keys) -> T? {
        guard let data = dataValue(for: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func dataValue(for key: Keys) -> Data? {
        let nativeQuery: [SecurityKeys: Any] = [
            .className: SecurityKeys.genericPassword.rawValue,
            .attributeService: key.rawValue,
            .attributeAccount: "local",
            .returnData: kCFBooleanTrue as Any,
            .matchLimit: SecurityKeys.matchLimitOne.rawValue
        ]
        let keychainQuery = SecurityKeys.dictionaryFrom(nativeQuery)

        var retrievedData: AnyObject?
        let status = SecItemCopyMatching(keychainQuery, &retrievedData)
        if status == errSecSuccess, let data = retrievedData as? Data {
            return data
        }
        return nil
    }

}
