//
//  GradientView.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 14/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import QuartzCore

final class GradientView: UIView {

    private weak var gradientMaskLayer: CAGradientLayer!

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        let layer = CAGradientLayer()
        self.gradientMaskLayer = layer
        layer.frame = bounds
        self.layer.mask = layer
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        backgroundColor = .background
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientMaskLayer.frame = bounds
    }

}
