//
//  ActiveBannerView.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 30.12.2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ActiveBannerView: UIView {

    enum Style {
        case red, gray
    }

    var style: Style = .red {
        didSet {
            switch style {
            case .red:
                backgroundColor = Asset.alertRed.color
                titleLabel.textColor = UIColor.white

                [closeButton, moreInfoButton].forEach {
                    $0?.backgroundColor = UIColor.white
                    $0?.setTitleColor(Asset.alertRed.color, for: .normal)
                }
            case .gray:
                backgroundColor = .secondaryGroupedBackground
                titleLabel.textColor = .textLabel

                [closeButton, moreInfoButton].forEach {
                    $0?.backgroundColor = Button.Style.dashboard.backgroundColor
                    $0?.setTitleColor(Button.Style.dashboard.textColor, for: .normal)
                }
            }
        }
    }

    private var shadowColor: CGColor {
        if #available(iOS 13.0, *) {
            return UIColor.textLabel.resolvedColor(with: traitCollection).withAlphaComponent(0.2).cgColor
        } else {
            return UIColor.textLabel.withAlphaComponent(0.2).cgColor
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: Button!
    @IBOutlet private weak var moreInfoButton: Button!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 9.0
        layer.shadowColor = shadowColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 1
    }

    func config(with title: String, closeTitle: String, moreInfoTitle: String) {
        titleLabel.text = title
        closeButton.setTitle(closeTitle)
        moreInfoButton.setTitle(moreInfoTitle)
    }

}
