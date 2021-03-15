//
//  Color.swift
//  eRouska
//
//  Created by Michal Šrůtek on 17/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }

    static var textLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }

    static var secondaryTextLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return UIColor(white: 0.5, alpha: 0)
        }
    }

    static var background: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    static var secondaryGroupedBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemGroupedBackground
        } else {
            return .groupTableViewBackground
        }
    }
}
