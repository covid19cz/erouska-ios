//
//  NSLayoutHelper.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 21/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

@IBDesignable class LayoutConstraintHelper : NSLayoutConstraint {
    @IBInspectable var iP6AndSmaller: CGFloat = 0.0 {
        didSet { deviceConstant(0..<600, value: iP6AndSmaller) }
    }
    @IBInspectable var iP6PlusAndBigger: CGFloat = 0.0 {
        didSet { deviceConstant(600..<10_000, value: iP6PlusAndBigger) }
    }

    func deviceConstant(_ size: Range<CGFloat>, value: CGFloat) {
        if size.contains(UIScreen.main.bounds.height) {
            constant = value
        }
    }
}
