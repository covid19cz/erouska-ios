//
//  PreviousRiskyEncountersVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxRealm
import RxDataSources

final class PreviousRiskyEncountersVC: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private let viewModel = PreviousRiskyEncountersVM()
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<PreviousRiskyEncountersVM.Section>!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        dataSource = nil

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setupDataSource()
    }

    required init?(coder: NSCoder) {
        dataSource = nil

        super.init(coder: coder)

        setupDataSource()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.tableFooterView = UIView()
    }

    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<PreviousRiskyEncountersVM.Section>(configureCell: { [weak self] _, _, _, item in
            self?.configureCell(item) ?? UITableViewCell()
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionModels[index].model
        }
    }

    private func configureCell(_ item: Exposure) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousRiskyEncountersCell") ?? UITableViewCell()
        cell.textLabel?.text = self.viewModel.dateFormatter.string(from: item.date)
        cell.selectionStyle = .none
        return cell
    }

}
