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

}

class RoundedButtonClear: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        layer.borderWidth = 1

        backgroundColor = .white

        titleLabel?.textAlignment = .center
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        setTitleColor(.systemBlue, for: .normal)
    }

}

