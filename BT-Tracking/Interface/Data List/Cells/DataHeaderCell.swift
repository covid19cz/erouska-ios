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
        segmentedControl.setTitle("Vše", forSegmentAt: 0)
        segmentedControl.setTitle("Blízka setkání", forSegmentAt: 1)

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
        
        enum CloseEncounters {
            case none, option1, option2
            
            func text(for count: Int, days: Int) -> String {
                switch self {
                case .none: return "Za posledních \(days) dní jste nepotkali žádné uživatele aplikace eRouška"
                case .option1: return "Za posledních \(days) dní jste potkali \(count) uživatele aplikace eRouška"
                case .option2: return "Za posledních \(days) dní jste potkali \(count) uživatelů aplikace eRouška"
                }
            }
        }
        
        func closeEncounts(for count: Int) -> CloseEncounters {
            switch (count, count % 10, count % 100) {
            case (0, _, _): return .none
            case (11...19, _, _): return .option2
            case (_, _, 11...19): return .option2
            case (_, 1...4, _): return .option1
            default: return .option2
            }
        }
        
        return closeEncounts(for: count).text(for: count, days: days)
    }
}
