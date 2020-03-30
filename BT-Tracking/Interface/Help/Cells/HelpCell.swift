//
//  HelpCell.swift
//  BT-Tracking
//
//  Created by Bogdan Kurpakov on 30/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HelpCell: UITableViewCell {

    static let identifier = "helpCell"

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    func configure(data: HelpVM.HelpData) {
        titleLabel.text = data.title
        descriptionLabel.text = data.description
    }
}
