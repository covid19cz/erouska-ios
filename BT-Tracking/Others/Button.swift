//
//  Button.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

class RoundedButtonFilled: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 16
        layer.masksToBounds = true

        backgroundColor = .systemBlue

        titleLabel?.textAlignment = .center
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        setTitleColor(.white, for: .normal)
    }

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .systemBlue : .systemGray
        }
    }

}

class RoundedButtonClear: UIButton {

    private var borderColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "ButtonBorder")?.resolvedColor(with: traitCollection).withAlphaComponent(0.12) ?? UIColor.clear
        } else {
            return UIColor(named: "ButtonBorder")?.withAlphaComponent(0.12) ?? UIColor.clear
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        layer.borderColor = borderColor.cgColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = 1

        backgroundColor = .clear

        titleLabel?.textAlignment = .center
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        setTitleColor(.systemBlue, for: .normal)
    }

}

