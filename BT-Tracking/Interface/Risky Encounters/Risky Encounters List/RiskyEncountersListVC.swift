//
//  RiskyEncountersListVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class RiskyEncountersListVC: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var viewModel: RiskyEncountersListVM!
    private let mainSymptomCellReusableIndetifier = "RiskyEncountersListCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable(viewModel.title)
        titleLabel.text = Localizable(viewModel.headline)

        tableView.tableFooterView = UIView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard let header = tableView.tableHeaderView else { return }
        header.frame.size.height = header.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0)).height
    }
}

extension RiskyEncountersListVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: mainSymptomCellReusableIndetifier) as! RiskyEncountersListCell
        cell.config(with: viewModel.items[indexPath.row])
        return cell
    }
}
