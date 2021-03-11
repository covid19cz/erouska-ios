//
//  HelpSectionCell.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import UIKit
import AlamofireImage

class HelpSectionCell: UITableViewCell {

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var sectionLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    func config(with title: String, subtitle: String, icon: String, image: UIImage?) {
        sectionLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle.isEmpty
        if let image = image {
            iconView.image = image
        } else if let url = URL(string: icon) {
            iconView.af.setImage(withURL: url)
        }
    }

}
