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
    @IBOutlet weak var withSymptomsHeaderLabel: UILabel!
    @IBOutlet weak var withSymptomsLabel: UILabel!
    @IBOutlet weak var withoutSymptomsHeaderLabel: UILabel!
    @IBOutlet weak var withoutSymptomsLabel: UILabel!
}

final class RiskyEncountersNegativeView: UIStackView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var previousRiskyEncountersButton: RoundedButtonClear!
}

final class RiskyEncountersVC: UIViewController {
    @IBOutlet weak var positiveView: RiskyEncountersPositiveView!
    @IBOutlet weak var negativeView: RiskyEncountersNegativeView!
    @IBOutlet weak var menuItemsStack: UIStackView!
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = RiskyEncountersVM()
    private let disposeBag = DisposeBag()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))

        positiveView.withSymptomsHeaderLabel.text = Localizable(viewModel.withSymptomsHeaderKey)
        positiveView.withSymptomsLabel.text = viewModel.withSymptoms
        positiveView.withoutSymptomsHeaderLabel.text = Localizable(viewModel.withoutSymptomsHeaderKey)
        positiveView.withoutSymptomsLabel.text = viewModel.withoutSymptoms

        negativeView.titleLabel.text = viewModel.negativeTitle
        negativeView.bodyLabel.text = viewModel.negativeBody
        negativeView.previousRiskyEncountersButton.localizedTitle(viewModel.previousRiskyEncountersButton)

        viewModel.riskyEncounterDateToShow.subscribe(
            onNext: { [weak self] dateToShow in
                guard let self = self else { return }
                let isPositive = dateToShow != nil
                self.positiveView.isHidden = !isPositive
                self.negativeView.isHidden = isPositive
                self.menuItemsStack.isHidden = !isPositive

                if let date = dateToShow {
                    self.positiveView.titleLabel.text = String(format: RemoteValues.riskyEncountersTitle, self.dateFormatter.string(from: date)) + Localizable("risky_encounters_positive_title")
                } else {
                    self.positiveView.titleLabel.text = ""
                }
            }
        ).disposed(by: disposeBag)

        viewModel.shouldShowPreviousRiskyEncounters.subscribe(
            onNext: { [weak self] shouldShowPreviousRiskyEncounters in
                guard let self = self else { return }
                self.negativeView.previousRiskyEncountersButton.isHidden = !shouldShowPreviousRiskyEncounters
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

    @IBAction func showPreviousRiskyEncounters(_ sender: Any) {
        performSegue(withIdentifier: "previousRiskyEncounters", sender: nil)
    }
}

extension RiskyEncountersVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")!
        let item = viewModel.menuItems[indexPath.row]
        cell.imageView?.image = item.icon.withRenderingMode(.alwaysOriginal)
        cell.textLabel?.text = item.localizedTitle
        return cell
    }
}

extension RiskyEncountersVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch viewModel.menuItems[indexPath.row] {
        case .mainSymptoms:
            performSegue(withIdentifier: "mainSymptoms", sender: nil)
        case .preventTransmission:
            performSegue(withIdentifier: "preventTransmission", sender: nil)
        case .previousRiskyEncounters:
            performSegue(withIdentifier: "previousRiskyEncounters", sender: nil)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
