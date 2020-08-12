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
        titleLabel.text = Localizable(viewModel.content?.headline ?? "")

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 76
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let header = tableView.tableHeaderView else { return }
        header.frame.size.height = header.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0)).height
    }
}

extension RiskyEncountersListVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.content?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: mainSymptomCellReusableIndetifier) as! RiskyEncountersListCell
        if let item = viewModel.content?.items[indexPath.row] {
            cell.config(with: item)
        }
        return cell
    }
}
