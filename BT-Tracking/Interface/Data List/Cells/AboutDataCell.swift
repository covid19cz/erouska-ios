//
//  AboutDataCell.swift
//  eRouska
//
//  Created by Tomas Svoboda on 15/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class AboutDataCell: UITableViewCell {

    static let identifier = "aboutDataCell"

    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.localizedText("data_list_info_button")
    }

}
