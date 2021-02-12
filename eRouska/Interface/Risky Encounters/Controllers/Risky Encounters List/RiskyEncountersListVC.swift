//
//  RiskyEncountersListVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class RiskyEncountersListVC: UIViewController {
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var footerLabel: UILabel!

    var viewModel: RiskyEncountersListVM!
    private let mainSymptomCellReusableIdentifier = "RiskyEncountersListCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.localizedTitle
        headerLabel.text = viewModel.content?.headline
        footerLabel.text = viewModel.content?.footer

        tableView.estimatedRowHeight = 76
        tableView.rowHeight = UITableView.automaticDimension
        if headerLabel.text == nil {
            tableView.tableHeaderView = nil
        }
        if footerLabel.text == nil {
            tableView.tableFooterView = nil
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let header = tableView.tableHeaderView {
            header.frame.size.height = header.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0)).height
        }
        if let footer = tableView.tableFooterView {
            footer.frame.size.height = footer.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0)).height
        }
    }
}

extension RiskyEncountersListVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.content?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: mainSymptomCellReusableIdentifier) as? RiskyEncountersListCell
        if let item = viewModel.content?.items[indexPath.row] {
            cell?.config(with: item)
        }
        return cell ?? UITableViewCell()
    }
}
