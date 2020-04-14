//
//  ScanListVC.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import FirebaseAuth
import RxCocoa
import RxDataSources
import RxSwift

final class ScanListVC: UIViewController, UITableViewDelegate {
    @IBOutlet private var tableView: UITableView!

    private var dataSource: RxTableViewSectionedAnimatedDataSource<ScanListVM.SectionModel>!
    private var viewModel = ScanListVM(scannerStore: AppDelegate.shared.scannerStore)
    private let bag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *) {
            navigationController?.tabBarItem.image = UIImage(systemName: "wifi")
        } else {
            navigationController?.tabBarItem.image = UIImage(named: "wifi")?.resize(toWidth: 30)
        }

        navigationItem.largeTitleDisplayMode = .never

        AppDelegate.shared.advertiser.didChangeID = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }

        setupTableView()
    }

    // MARK: - Actions

    @IBAction func signOutAction(_ sender: Any) {
        do {
            AppDelegate.shared.advertiser.stop()
            AppDelegate.shared.scanner.stop()
            AppDelegate.shared.scannerStore.deleteAllData()

            AppSettings.deleteAllData()

            try Auth.auth().signOut()
            UserDefaults.resetStandardUserDefaults()

            let storyboard = UIStoryboard(name: "Signup", bundle: nil)
            view.window?.rootViewController = storyboard.instantiateInitialViewController()
        } catch {
            show(error: error)
        }
    }

    @IBAction func clearAction(_ sender: Any) {
        viewModel.clear()
    }

    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - TableView

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension

        dataSource = RxTableViewSectionedAnimatedDataSource<ScanListVM.SectionModel>(configureCell: { _, tableView, indexPath, row in
            let cell: UITableViewCell?
            switch row {
            case let .info(buid):
                let infoCell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier, for: indexPath) as? InfoCell
                infoCell?.configure(for: buid, tuid: AppDelegate.shared.advertiser.currentID)
                cell = infoCell
            case let .scan(scan):
                let scanCell = tableView.dequeueReusableCell(withIdentifier: ScanCell.identifier, for: indexPath) as? ScanCell
                scanCell?.configure(for: scan)
                cell = scanCell
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

    // MARK: - TableView section header

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        29
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let datasourceSection = dataSource.sectionModels[section]
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionTitleCell.identifier, for: IndexPath(row: 0, section: section)) as? SectionTitleCell
        cell?.configure(for: datasourceSection.model.identity)
        return cell?.contentView ?? UIView()
    }
}
