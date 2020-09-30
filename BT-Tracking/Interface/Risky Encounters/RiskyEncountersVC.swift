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
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var withSymptomsHeaderLabel: UILabel!
    @IBOutlet private weak var withSymptomsLabel: UILabel!
    @IBOutlet private weak var withoutSymptomsHeaderLabel: UILabel!
    @IBOutlet private weak var withoutSymptomsLabel: UILabel!

    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            titleLabel.text
        }
    }

    func setup(withSymptomsHeader: String, withSymptoms: String, withoutSymptomsHeader: String, withoutSymptoms: String) {
        withSymptomsHeaderLabel.text = withSymptomsHeader
        withSymptomsLabel.text = withSymptoms
        withoutSymptomsHeaderLabel.text = withoutSymptomsHeader
        withoutSymptomsLabel.text = withoutSymptoms
    }
}

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

final class RiskyEncountersVC: UIViewController {
    @IBOutlet private weak var positiveView: RiskyEncountersPositiveView!
    @IBOutlet private weak var negativeView: RiskyEncountersNegativeView!
    @IBOutlet private weak var menuItemsStack: UIStackView!
    @IBOutlet private weak var tableView: UITableView!

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

        positiveView.setup(
            withSymptomsHeader: L10n.riskyEncountersPositiveWithSymptomsHeader,
            withSymptoms: viewModel.withSymptoms,
            withoutSymptomsHeader: L10n.riskyEncountersPositiveWithoutSymptomsHeader,
            withoutSymptoms: viewModel.withoutSymptoms
        )

        negativeView.setup(
            title: viewModel.negativeTitle,
            body: viewModel.negativeBody,
            previousRiskyEncounters: viewModel.previousRiskyEncountersButton
        )

        viewModel.riskyEncounterDateToShow.subscribe(
            onNext: { [weak self] dateToShow in
                guard let self = self else { return }
                let isPositive = dateToShow != nil
                self.positiveView.isHidden = !isPositive
                self.negativeView.isHidden = isPositive
                self.menuItemsStack.isHidden = !isPositive
                self.positiveView.title = nil

                if let date = dateToShow {
                    let formatted = String(format: RemoteValues.riskyEncountersTitle, self.dateFormatter.string(from: date))
                    self.positiveView.title = formatted + L10n.riskyEncountersPositiveTitle
                }
            }
        ).disposed(by: disposeBag)

        viewModel.shouldShowPreviousRiskyEncounters.subscribe(
            onNext: { [weak self] shouldShowPreviousRiskyEncounters in
                guard let self = self else { return }
                self.negativeView.isPreviousRiskyEncountersHidden = !shouldShowPreviousRiskyEncounters
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

    @IBAction private func showPreviousRiskyEncounters(_ sender: Any) {
        performSegue(withIdentifier: "previousRiskyEncounters", sender: nil)
    }
}

extension RiskyEncountersVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell") ?? UITableViewCell()
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
