//
//  ScanningInfoCell.swift
//  eRouska
//
//  Created by Tomas Svoboda on 15/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ScanningInfoCell: UITableViewCell {

    static let identifier = "scanningInfoCell"

    @IBOutlet private weak var infoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        infoLabel.localizedText("data_list_headline")
    }

}
