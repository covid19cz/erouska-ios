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

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    func configure(with numberOfScans: Int) {
        titleLabel.text = closeEncountersText(for: numberOfScans, days: RemoteValues.persistDataDays)
        segmentedControl.setTitle("Blízka setkání", forSegmentAt: 0)
        segmentedControl.setTitle("Vše", forSegmentAt: 1)

        if #available(iOS 13, *) {
            let image = UIImage(systemName: "questionmark.circle")
            infoButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: "questionmark.circle")?
                .resize(toWidth: 19)?
                .withRenderingMode(.alwaysTemplate)
            infoButton.setImage(image, for: .normal)
        }
    }
    
    private func closeEncountersText(for count: Int, days: Int) -> String {
        switch count {
        case 0: return "Za posledních \(days) dní jste nepotkali žádné uživatele aplikace eRouška"
        case 1...4: return "Za posledních \(days) dní jste potkali \(count) uživatele aplikace eRouška"
        default: return "Za posledních \(days) dní jste potkali \(count) uživatelů aplikace eRouška"
        }
    }
}
