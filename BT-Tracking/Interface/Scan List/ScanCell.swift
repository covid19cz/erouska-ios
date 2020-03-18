//
//  ScanCell.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

class ScanCell: UITableViewCell {

    static let identifier = "scanCell"
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    func configure(for scan: Scan) {
        nameLabel.text = scan.name
        identifierLabel.text = scan.identifier
        dateLabel.text = scan.date.description
        rssiLabel.text = String(scan.rssi)
    }
}
