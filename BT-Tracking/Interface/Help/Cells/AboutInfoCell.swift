//
//  AboutInfoCell.swift
// eRouska
//
//  Created by Lukáš Foldýna on 21/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class AboutInfoCell: UITableViewCell {

    static let identifier = "infoCell"

    @IBOutlet private weak var infoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        infoLabel.localizedText("about_info")
    }

}
