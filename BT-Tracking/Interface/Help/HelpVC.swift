//
//  HelpVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class HelpVC: UIViewController, UITableViewDelegate {

    @IBOutlet private weak var tableView: UITableView!

    private var dataSource: RxTableViewSectionedAnimatedDataSource<HelpVM.SectionModel>!
    private let viewModel = HelpVM()
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        setupTableView()
    }

    private func setupTabBar() {
        if #available(iOS 13, *) {
            navigationController?.tabBarItem.image = UIImage(systemName: "questionmark.circle")
        } else {
            navigationController?.tabBarItem.image = UIImage(named: "questionmark.circle")?.resize(toWidth: 26)
        }
    }

    // MARK: - TableView
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension

        dataSource = RxTableViewSectionedAnimatedDataSource<HelpVM.SectionModel>(configureCell: { datasource, tableView, indexPath, row in
            let cell: UITableViewCell?
            switch row {
            case .main(let data):
                let helpCell = tableView.dequeueReusableCell(withIdentifier: HelpCell.identifier, for: indexPath) as? HelpCell
                helpCell?.configure(data: data)
                cell = helpCell
            }
            return cell ?? UITableViewCell()
        })

        viewModel.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        tableView.rx.setDelegate(self)
            .disposed(by: bag)

        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .fade)
    }

    // MARK: - Actions

    @IBAction private func aboutAction() {
        guard let url = URL(string: RemoteValues.aboutLink) else { return }
        openURL(URL: url)
    }

}
