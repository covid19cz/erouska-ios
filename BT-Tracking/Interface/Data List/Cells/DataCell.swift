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
        RSSILabel.textColor = color(forScan: scan)
    }

    private func color(forScan scan: Scan) -> UIColor {
        switch scan.expositionLevel {
        case .level1: return UIColor(rgb: 0x4CAF50)
        case .level2: return UIColor(rgb: 0x8BC34A)
        case .level3: return UIColor(rgb: 0xCDDC39)
        case .level4: return UIColor(rgb: 0xFFEB3B)
        case .level5: return UIColor(rgb: 0xFFC107)
        case .level6: return UIColor(rgb: 0xFF9800)
        case .level7: return UIColor(rgb: 0xFF5722)
        case .level8: return UIColor(rgb: 0xF44336)
        }
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
