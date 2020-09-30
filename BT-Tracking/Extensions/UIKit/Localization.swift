//
//  Localization.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

func Localizable(_ text: String, comment: String? = nil) -> String {
    return NSLocalizedString(text, comment: comment ?? text)
}

extension UINavigationItem {

    func localizedTitle(_ text: String, comment: String? = nil) {
        title = Localizable(text, comment: comment)
    }

    func localizedTitle(_ text: Localization) {
        localizedTitle(text.rawValue)
    }

}

extension UITabBarItem {

    func localizedTitle(_ text: String, comment: String? = nil) {
        title = Localizable(text, comment: comment)
    }

    func localizedTitle(_ text: Localization) {
        localizedTitle(text.rawValue)
    }

}

extension UIBarButtonItem {

    func localizedTitle(_ text: String, comment: String? = nil) {
        title = Localizable(text, comment: comment)
    }

    func localizedTitle(_ text: Localization) {
        localizedTitle(text.rawValue)
    }

}

extension UIButton {

    func localizedTitle(_ text: String, comment: String? = nil) {
        setTitle(Localizable(text, comment: comment), for: .normal)
    }

    func localizedTitle(_ text: Localization) {
        localizedTitle(text.rawValue)
    }

}

extension UILabel {

    func localizedText(_ text: String, comment: String? = nil, values: CVarArg...) {
        self.text = String(format: Localizable(text, comment: comment), arguments: values)
    }

    func localizedText(_ text: Localization, values: CVarArg...) {
        localizedText(text.rawValue, values: values)
    }

}

extension UITextView {

    func localizedText(_ text: String, comment: String? = nil) {
        self.text = Localizable(text, comment: comment)
    }

    func localizedText(_ text: Localization, comment: String? = nil) {
        localizedText(text.rawValue)
    }

}

extension UITextField {

    func localizedPlaceholder(_ text: String, comment: String? = nil) {
        self.placeholder = Localizable(text, comment: comment)
    }

    func localizedPlaceholder(_ text: Localization, comment: String? = nil) {
        localizedPlaceholder(text.rawValue)
    }

    func localizedText(_ text: String, comment: String? = nil) {
        self.text = Localizable(text, comment: comment)
    }

    func localizedText(_ text: Localization, comment: String? = nil) {
        localizedText(text.rawValue)
    }

}

extension Localization {

    var localized: String {
        Localizable(rawValue)
    }

}
