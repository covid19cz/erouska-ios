//
//  RiskyEncountersVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class RiskyEncountersPositiveView: UIStackView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var mainSymptomsButton: UIButton!
    @IBOutlet weak var preventTransmissionButton: UIButton!
    @IBOutlet weak var previousRiskyEncountersButton: UIButton!
}

final class RiskyEncountersVC: UIViewController {
    @IBOutlet weak var positiveView: RiskyEncountersPositiveView!

    private let viewModel = RiskyEncountersVM()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable(viewModel.title)
        positiveView.isHidden = viewModel.riskyEncouterDateToShow != nil
    }

    @IBAction func showMainSymptoms(_ sender: Any) {
        // TODO:
    }

    @IBAction func showPreventTransmission(_ sender: Any) {
        // TODO:
    }

    @IBAction func showPreviousRiskyEncounters(_ sender: Any) {
        // TODO:
    }
}
