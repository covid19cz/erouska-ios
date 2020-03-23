//
//  SectionTitleCell.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 22/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

class SectionTitleCell: UITableViewCell {

    static let identifier = "sectionTitleCell"

    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(for title: String) {
        titleLabel.text = title
    }
}
