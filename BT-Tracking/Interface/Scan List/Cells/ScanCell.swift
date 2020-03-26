//
//  ScanCell.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ScanCell: UITableViewCell {

    static let identifier = "scanCell"

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var identifierLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var rssiLabel: UILabel!
    @IBOutlet private weak var platformLabel: UILabel!

    func configure(for scan: Scan) {
        nameLabel.text = scan.name + ", buid: " + scan.buid
        identifierLabel.text = scan.bluetoothIdentifier
        dateLabel.text = ScanCell.formatter.string(from: scan.date)
        rssiLabel.text = String(scan.rssi)  + " dB"
        platformLabel.text = scan.platform.rawValue
    }
    
    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()

}
