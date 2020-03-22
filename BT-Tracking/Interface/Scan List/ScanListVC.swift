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

class ScanListVC: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<ScanListVM.SectionModel>!
    private let bag = DisposeBag()
    private let viewModel = ScanListVM(scannerStore: AppDelegate.delegate.scannerStore)
    
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
    
    @IBAction func clear(_ sender: Any) {
        viewModel.clear()
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
        tableView.rowHeight = 120

        dataSource = RxTableViewSectionedAnimatedDataSource<ScanListVM.SectionModel>(configureCell: { datasource, tableView, indexPath, row in
            switch row {
            case .scan(let scan):
                let cell = tableView.dequeueReusableCell(withIdentifier: ScanCell.identifier, for: indexPath) as! ScanCell
                cell.configure(for: scan)
                return cell
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionTitleCell.identifier, for: IndexPath(row: 0, section: section)) as! SectionTitleCell
        cell.configure(for: datasourceSection.model.identity)
        return cell.contentView
    }
}
