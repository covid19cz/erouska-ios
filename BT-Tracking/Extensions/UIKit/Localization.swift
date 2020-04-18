//
//  Localization.swift
//  eRouska Dev
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

}

extension UITabBarItem {

    func localizedTitle(_ text: String, comment: String? = nil) {
        title = Localizable(text, comment: comment)
    }

}

extension UIBarButtonItem {

    func localizedTitle(_ text: String, comment: String? = nil) {
        title = Localizable(text, comment: comment)
    }

}

extension UIButton {

    func localizedTitle(_ text: String, comment: String? = nil) {
        setTitle(Localizable(text, comment: comment), for: .normal)
    }

}

extension UILabel {

    func localizedText(_ text: String, comment: String? = nil, values: CVarArg...) {
        self.text = String(format: Localizable(text, comment: comment), arguments: values)
    }

}

extension UITextField {

    func localizedPlaceholder(_ text: String, comment: String? = nil) {
        self.placeholder = Localizable(text, comment: comment)
    }

    func localizedText(_ text: String, comment: String? = nil) {
        self.text = Localizable(text, comment: comment)
    }

}
