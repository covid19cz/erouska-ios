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
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var RSSILabel: UILabel!

    func configure(for scan: Scan) {
        buidLabel.text = String(scan.buid.prefix(6)) + "..."
        dateLabel.text = Self.dateFormatter.string(from: scan.date)
        timeLabel.text = Self.timeFormatter.string(from: scan.date)
        RSSILabel.text = String(scan.rssi) + " dB"
    }

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    private static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
}
