//
//  Button.swift
//  eRouska
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
        case exposureBanner
        case dashboard

        var backgroundColor: UIColor {
            switch self {
            case .filled:
                return .systemBlue
            case .clear:
                return .clear
            case .disabled:
                return .background
            case .exposureBanner:
                return .white
            case .dashboard:
                return Asset.dasboardButton.color
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
            case .exposureBanner:
                return Asset.alertRed.color
            case .dashboard:
                return .systemBlue
            }
        }

        func setup(with button: UIButton, borderColor: UIColor?) {
            button.backgroundColor = backgroundColor

            button.layer.cornerRadius = 16
            button.layer.masksToBounds = true

            button.layer.borderWidth = [.filled, .exposureBanner, .dashboard].contains(self) ? 0 : 1
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
        case .filled, .exposureBanner, .dashboard:
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

final class RoundedButtonClear: Button {

    override func awakeFromNib() {
        style = .clear
        super.awakeFromNib()
    }
}

final class ExposureBannerButton: Button {

    override func awakeFromNib() {
        style = .exposureBanner
        super.awakeFromNib()
    }
}

final class DashboardButton: Button {

    convenience init() {
        self.init(type: .system)
        awakeFromNib()
    }

    override func awakeFromNib() {
        style = .dashboard
        titleLabel?.font = .systemFont(ofSize: 15)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        super.awakeFromNib()
    }
}
