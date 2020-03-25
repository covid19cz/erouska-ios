//
//  Button.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

class Button: UIButton {

    enum Style {
        case filled
        case clear

        var backgroundColor: UIColor {
            switch self {
            case .filled:
                return .systemBlue
            case .clear:
                return .clear
            }
        }

        var textColor: UIColor {
            switch self {
            case .filled:
                return .white
            case .clear:
                return .systemBlue
            }
        }

        func setup(with button: UIButton, borderColor: UIColor?) {
            button.backgroundColor = backgroundColor

            button.layer.cornerRadius = 16
            button.layer.masksToBounds = true

            button.layer.borderWidth = self == .filled ? 0 : 1
            button.layer.borderColor = borderColor?.cgColor

            button.titleLabel?.textAlignment = .center
            button.setTitleColor(textColor, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    var style: Style = .filled {
        didSet {
            style.setup(with: self, borderColor: borderColor)
        }
    }

    private var borderColor: UIColor? {
        switch style {
        case .filled:
            return nil
        case .clear:
            if #available(iOS 13.0, *) {
                return UIColor(named: "ButtonBorder")?.resolvedColor(with: traitCollection).withAlphaComponent(0.12) ?? UIColor.clear
            } else {
                return UIColor(named: "ButtonBorder")?.withAlphaComponent(0.12) ?? UIColor.clear
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        style.setup(with: self, borderColor: borderColor)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        layer.borderColor = borderColor?.cgColor
    }

}

class RoundedButtonFilled: Button {

}

class RoundedButtonClear: Button {

    override func awakeFromNib() {
        style = .clear

        super.awakeFromNib()
    }

}

