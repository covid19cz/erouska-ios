//
//  CurrentDataCell.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 23/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class CurrentDataCell: UITableViewCell {

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel?

    func update(icon: UIImage, title: String, subtitle: String?) {
        iconView.image = icon
        titleLabel.text = title
        subtitleLabel?.text = subtitle
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        separatorInset = .init(top: 0, left: iconView.frame.maxX + 16, bottom: 0, right: 0)
    }

}
