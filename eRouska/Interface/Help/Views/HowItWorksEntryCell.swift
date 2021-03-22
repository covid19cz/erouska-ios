//
//  HowItWorksEntryCell.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 30.12.2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HowItWorksEntryCell: UITableViewCell {

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!

    func config(with title: String, body: String, icon: ImageAsset) {
        iconView.image = icon.image
        titleLabel.text = title
        bodyLabel.text = body
    }

}
