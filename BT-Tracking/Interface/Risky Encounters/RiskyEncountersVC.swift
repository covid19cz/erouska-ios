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
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = RiskyEncountersVM()
    private let disposeBag = DisposeBag()
    private var menuItems = [RiskyEncountersVM.MenuItem]() {
        didSet {
            tableView.reloadData()
        }
    }

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
                let isPositive = dateToShow != nil
                self.positiveView.isHidden = !isPositive
                self.negativeView.isHidden = isPositive

                [RiskyEncountersVM.MenuItem.mainSymptoms, .preventTransmission].enumerated().forEach { index, item in
                    if let itemIndex = self.menuItems.firstIndex(of: item) {
                        self.menuItems.remove(at: itemIndex)
                    }
                    if isPositive {
                        self.menuItems.insert(item, at: index)
                    }
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
                if let itemIndex = self.menuItems.firstIndex(of: .previousRiskyEncounters) {
                    self.menuItems.remove(at: itemIndex)
                }
                if shouldShowPreviousRiskyEncounters {
                    self.menuItems.append(.previousRiskyEncounters)
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

extension RiskyEncountersVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")!
        let item = menuItems[indexPath.row]
        cell.imageView?.image = item.icon.withRenderingMode(.alwaysOriginal)
        cell.textLabel?.text = item.localizedTitle
        return cell
    }
}

extension RiskyEncountersVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch menuItems[indexPath.row] {
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
