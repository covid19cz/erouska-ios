//
//  DataListVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 23/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Reachability
import BackgroundTasks
import ExposureNotification

final class DataListVC: UIViewController, UITableViewDelegate {

    // MARK: -

    private var dataSource: RxTableViewSectionedAnimatedDataSource<DataListVM.SectionModel>!
    private let viewModel = DataListVM()
    private let bag = DisposeBag()

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        setupTabBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: indexPath, animated: animated)
    }

}

private extension DataListVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.deleteButton)
    }

    func setupTabBar() {
        navigationController?.tabBarItem.localizedTitle(viewModel.tabTitle)
        navigationController?.tabBarItem.image = viewModel.tabIcon
    }

    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension

        dataSource = RxTableViewSectionedAnimatedDataSource<DataListVM.SectionModel>(configureCell: { datasource, tableView, indexPath, row in
            switch row {
            case .scanningInfo:
                return tableView.dequeueReusableCell(withIdentifier: ScanningInfoCell.identifier, for: indexPath)
            case .aboutData:
                return tableView.dequeueReusableCell(withIdentifier: AboutDataCell.identifier, for: indexPath)
            case .header:
                return tableView.dequeueReusableCell(withIdentifier: DataHeaderCell.identifier, for: indexPath)
            }
        })

        viewModel.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        tableView.rx.setDelegate(self)
            .disposed(by: bag)

        tableView.rx.modelSelected(DataListVM.Section.Item.self)
            .filter { $0 == .aboutData }
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.pushViewController(DataCollectionInfoVC(), animated: true)
            })
            .disposed(by: bag)

        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .fade)

        viewModel.selectedSegmentIndex.accept(0)
    }

}
