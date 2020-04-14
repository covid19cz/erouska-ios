//
//  InputValidation.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 14/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

enum InputValidation {
    case prefix, number, smsCode

    var characterSet: CharacterSet {
        switch self {
        case .prefix:
            return CharacterSet(charactersIn: "+0123456789")
        case .number, .smsCode:
            return CharacterSet(charactersIn: "0123456789")
        }
    }

    var rangeLimit: ClosedRange<Int> {
        switch self {
        case .prefix:
            return 2...5
        case .number:
            return 9...9
        case .smsCode:
            return 6...6
        }
    }

    func validate(_ text: String) -> Bool {
        guard rangeLimit.contains(text.count), text == filtered(text) else { return false }
        return true
    }

    func filtered(_ text: String) -> String {
        let set = characterSet.inverted
        return text.components(separatedBy: set).joined()
    }

    func checkChange(_ oldString: String, _ newString: String) -> (result: Bool, edited: String?) {
        guard newString.count <= rangeLimit.upperBound else {
            let text = String(filtered(newString).prefix(rangeLimit.upperBound))
            return (result: false, edited: oldString == text ? nil : text)
        }
        return (result: true, edited: nil)
    }
}

extension UITextFieldDelegate {

    func validateTextChange(with type: InputValidation, textField: UITextField, changeCharactersIn range: NSRange, newString string: String) -> Bool {
        guard let text = textField.text else { return true }

        let candidate = NSString(string: text).replacingCharacters(in: range, with: string)
        let check = type.checkChange(text, candidate)
        if check.result {
            return true
        }
        DispatchQueue.main.async {
            textField.text = check.edited ?? text
            textField.sendActions(for: .valueChanged)
        }
        return false
    }

}
