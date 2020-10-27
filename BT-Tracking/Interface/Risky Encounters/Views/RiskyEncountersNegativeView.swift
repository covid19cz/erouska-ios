//
//  RiskyEncountersNegativeView.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 25/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class RiskyEncountersNegativeView: UIStackView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var previousRiskyEncountersButton: RoundedButtonClear!

    var isPreviousRiskyEncountersHidden: Bool {
        set {
            previousRiskyEncountersButton.isHidden = newValue
        }
        get {
            previousRiskyEncountersButton.isHidden
        }
    }

    func setup(title: String, body: String, previousRiskyEncounters: String) {
        titleLabel.text = title
        bodyLabel.text = body
        previousRiskyEncountersButton.setTitle(previousRiskyEncounters)
    }

}
