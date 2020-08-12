//
//  DataHeaderCell.swift
//  eRouska
//
//  Created by Bogdan Kurpakov on 28/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class DataHeaderCell: UITableViewCell {

    static let identifier = "headerCell"

    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var signalLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        segmentedControl.setTitle(Localizable("data_list_section_all"), forSegmentAt: 0)
        segmentedControl.setTitle(Localizable("data_list_section_nearby"), forSegmentAt: 1)

        dateLabel.localizedText("data_list_header_date")
        timeLabel.localizedText("data_list_header_time")
        idLabel.localizedText("data_list_header_id")
        signalLabel.localizedText("data_list_header_signal")
    }

}
