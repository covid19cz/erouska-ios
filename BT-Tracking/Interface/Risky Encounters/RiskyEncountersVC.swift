//
//  RiskyEncountersVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 07/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift

final class RiskyEncountersPositiveView: UIStackView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
}

final class RiskyEncountersVC: UIViewController {
    @IBOutlet weak var positiveView: RiskyEncountersPositiveView!
    @IBOutlet weak var negativeView: UIStackView!

    @IBOutlet weak var mainSymptomsButton: UIView!
    @IBOutlet weak var mainSymptomsSeparator: UIView!
    @IBOutlet weak var preventTransmissionButton: UIView!
    @IBOutlet weak var preventTransmissionSeparator: UIView!
    @IBOutlet weak var previousRiskyEncountersButton: UIView!
    @IBOutlet weak var previousRiskyEncountersSeparator: UIView!

    private let viewModel = RiskyEncountersVM()
    private let disposeBag = DisposeBag()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MM. yyyy"
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable(viewModel.title)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))

        positiveView.bodyLabel.text = viewModel.body

        viewModel.riskyEncouterDateToShow.subscribe(
            onNext: { [weak self] dateToShow in
                guard let self = self else { return }
                self.positiveView.isHidden = dateToShow == nil
                self.negativeView.isHidden = dateToShow != nil

                [self.mainSymptomsButton, self.mainSymptomsSeparator, self.preventTransmissionButton, self.preventTransmissionSeparator].forEach {
                    $0?.isHidden = self.positiveView.isHidden
                }

                if let date = dateToShow {
                    self.positiveView.titleLabel.text = String(format: RemoteValues.riskyEncountersTitle, self.dateFormatter.string(from: date))
                } else {
                    self.positiveView.titleLabel.text = ""
                }
            }
        ).disposed(by: disposeBag)

        viewModel.shouldShowPreviousRiskyEncounters.subscribe(
            onNext: { [weak self] shouldShowPreviousRiskyEncounters in
                guard let self = self else { return }
                [self.previousRiskyEncountersButton, self.previousRiskyEncountersSeparator].forEach {
                    $0?.isHidden = !shouldShowPreviousRiskyEncounters
                }
            }
        ).disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? RiskyEncountersListVC else { return }

        if segue.identifier == "mainSymptoms" {
            viewController.viewModel = MainSymptomsVM()
        } else if segue.identifier == "preventTransmission" {
            viewController.viewModel = PreventTransmissionVM()
        }
    }

    @IBAction private func closeAction() {
        dismiss(animated: true)
    }
}
