//
//  DataCell.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 23/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class DataCell: UITableViewCell {

    static let identifier = "dataCell"

    @IBOutlet private weak var buidLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var RSSILabel: UILabel!

    func configure(for scan: Scan) {
        buidLabel.text = scan.buid
        dateLabel.text = Self.formatter.string(from: scan.date)
        RSSILabel.text = String(scan.rssi) + " dB"
    }

    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()

}
