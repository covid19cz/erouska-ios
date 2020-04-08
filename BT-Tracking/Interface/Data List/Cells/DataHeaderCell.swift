//
//  DataHeaderCell.swift
//  BT-Tracking
//
//  Created by Bogdan Kurpakov on 28/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class DataHeaderCell: UITableViewCell {

    static let identifier = "headerCell"

    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    func configure(with numberOfScans: Int) {
        segmentedControl.setTitle("Vše", forSegmentAt: 0)
        segmentedControl.setTitle("Blízka setkání", forSegmentAt: 1)
    }
}
