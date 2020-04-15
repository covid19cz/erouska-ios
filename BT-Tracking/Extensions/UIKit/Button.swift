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
        case disabled

        var backgroundColor: UIColor {
            switch self {
            case .filled:
                return .systemBlue
            case .clear:
                return .clear
            case .disabled:
                return .clear
            }
        }

        var textColor: UIColor {
            switch self {
            case .filled:
                return .white
            case .clear:
                return .systemBlue
            case .disabled:
                return .systemGray
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
            if !isEnabled, style != .disabled {
                oldStyle = style
                style = .disabled
            }
            style.setup(with: self, borderColor: borderColor)
        }
    }

    private var oldStyle: Style = .filled

    override var isEnabled: Bool {
        get {
            super.isEnabled
        }
        set {
            super.isEnabled = newValue
            style = !newValue ? .disabled : oldStyle
        }
    }

    private var borderColor: UIColor? {
        switch style {
        case .filled:
            return nil
        case .clear, .disabled:
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

final class RoundedButtonFilled: Button {

}

final class MainScanningButton: Button {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            backgroundColor = UIColor.systemGray6
        } else {
            backgroundColor = UIColor(red: 237/255.0, green: 238/255.0, blue: 240/255.0, alpha: 1)
        }
        setTitleColor(.systemBlue, for: .normal)
    }
}

final class RoundedButtonClear: Button {

    override func awakeFromNib() {
        style = .clear
        super.awakeFromNib()
    }
}
