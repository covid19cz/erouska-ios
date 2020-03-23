//
//  ScanListVC.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import FirebaseAuth

final class ScanListVC: UIViewController, UITableViewDelegate {

    @IBOutlet private weak var tableView: UITableView!

    private var dataSource: RxTableViewSectionedAnimatedDataSource<ScanListVM.SectionModel>!
    private let viewModel = ScanListVM(scannerStore: AppDelegate.delegate.scannerStore)
    private let bag = DisposeBag()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        setup()
        setupTableView()
    }

    // MARK: - Actions

    @IBAction func signOutAction(_ sender: Any) {
        do {
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

    private func setup() {
        if AppDelegate.delegate.advertiser.isRunning != true {
            AppDelegate.delegate.advertiser.start()
        }

        if AppDelegate.delegate.scanner.isRunning != true {
            AppDelegate.delegate.scanner.start()
        }
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension

        dataSource = RxTableViewSectionedAnimatedDataSource<ScanListVM.SectionModel>(configureCell: { datasource, tableView, indexPath, row in
            let cell: UITableViewCell?
            switch row {
            case .info(let buid):
                let infoCell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier, for: indexPath) as? InfoCell
                infoCell?.configure(for: buid)
                cell = infoCell
            case .scan(let scan):
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
        return 29
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let datasourceSection = dataSource.sectionModels[section]
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionTitleCell.identifier, for: IndexPath(row: 0, section: section)) as? SectionTitleCell
        cell?.configure(for: datasourceSection.model.identity)
        return cell?.contentView ?? UIView()
    }

}
