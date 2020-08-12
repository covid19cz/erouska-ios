//
//  PreviousRiskyEncountersVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class PreviousRiskyEncountersVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = PreviousRiskyEncountersVM()
    private let reusableCellIdentifier = "PreviousRiskyEncountersCell"
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable(viewModel.title)

        tableView.tableFooterView = UIView()
    }
}

extension PreviousRiskyEncountersVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.previousExposures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellIdentifier)!
        cell.textLabel?.text = dateFormatter.string(from: viewModel.previousExposures[indexPath.row].date)
        cell.selectionStyle = .none
        return cell
    }
}

extension PreviousRiskyEncountersVC: UITableViewDelegate {

}
