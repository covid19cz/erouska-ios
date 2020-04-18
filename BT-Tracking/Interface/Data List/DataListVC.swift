//
//  DataListVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 23/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
#if !targetEnvironment(macCatalyst)
import FirebaseAuth
import FirebaseStorage
#endif
import Reachability

final class DataListVC: UIViewController, UITableViewDelegate {

    // MARK: -

    private var dataSource: RxTableViewSectionedAnimatedDataSource<DataListVM.SectionModel>!
    private let viewModel = DataListVM()
    private let bag = DisposeBag()

    private var writer: CSVMakering?

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var sendButton: Button!


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        setupTabBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: tableView)
        buttonsView.defaultContentInset.bottom += 10
        buttonsView.resetInsets(in: tableView)

        setupStrings()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: indexPath, animated: animated)
    }

    // MARK: - Actions

    @IBAction private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.selectedSegmentIndex.accept(sender.selectedSegmentIndex)
    }

    @IBAction private func sendReportAction() {
        let controller = UIAlertController(
            title: "Požádal vás pracovník hygienické stanice o zaslání seznamu telefonů, se kterými jste se setkali?",
            message: "S odeslanými daty bude Ministerstvo zdravotnictví a jemu podřízení hygienici pracovat na základě vašeho souhlasu podle podmínek zpracování.",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Ano, odeslat", style: .default, handler: { [weak self] _ in
            self?.sendReport()
        }))
        controller.addAction(UIAlertAction(title: "Ne", style: .cancel, handler: { _ in
            self.showAlert(
                title: "Sdílejte data jen v případě, že vás pracovník hygienické stanice poprosí o jejich zaslání. To se stane pouze tehdy, když budete v okruhu lidí nakažených koronavirem, nebo test prokáže vaši nákazu",
                message: ""
            )
        }))
        controller.preferredAction = controller.actions.first
        present(controller, animated: true)
    }

}

private extension DataListVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.deleteButton)

        sendButton.localizedTitle(viewModel.sendButton)
    }

    func setupTabBar() {
        navigationController?.tabBarItem.localizedTitle(viewModel.title)
        navigationController?.tabBarItem.image = viewModel.tabBarIcon
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
            case .data(let scan):
                let cell = tableView.dequeueReusableCell(withIdentifier: DataCell.identifier, for: indexPath) as? DataCell
                cell?.configure(for: scan)
                return cell ?? UITableViewCell()
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

    // MARK: - Report

    func sendReport() {
        guard (AppSettings.lastUploadDate ?? Date.distantPast) + RemoteValues.uploadWaitingMinutes < Date() else {
            showAlert(
                title: "Data jsme už odeslali. Prosím počkejte 15 minut a pošlete je znovu.",
                message: ""
            )
            return
        }

        guard let connection = try? Reachability().connection, connection != .unavailable else {
            showAlert(
                title: "Nepodařilo se nám odeslat data",
                message: "Zkontrolujte připojení k internetu a zkuste to znovu"
            )
            return
        }

        createCSVFile()
    }

    func createCSVFile() {
        showProgress()

        let fileDate = Date()

        writer = CSVMaker(fromDate: nil) // AppSettings.lastUploadDate, set to last upload date, if we want increment upload
        writer?.createFile(callback: { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                self.uploadCSVFile(fileURL: result.fileURL, metadata: result.metadata, fileDate: fileDate)
            } else if let error = error {
                self.hideProgress()
                self.show(error: error, title: "Nepodařilo se vytvořit soubor se setkáními")
            }
        })
    }

    func uploadCSVFile(fileURL: URL, metadata: [String: String], fileDate: Date) {
        let path = "proximity/\(Auth.auth().currentUser?.uid ?? "")/\(KeychainService.BUID ?? "")"
        let fileName = "\(Int(fileDate.timeIntervalSince1970 * 1000)).csv"

        let storage = Storage.storage()
        let storageReference = storage.reference()
        let fileReference = storageReference.child("\(path)/\(fileName)")
        let storageMetadata = StorageMetadata()
        storageMetadata.customMetadata = metadata

        fileReference.putFile(from: fileURL, metadata: storageMetadata) { [weak self] (metadata, error) in
            guard let self = self else { return }
            self.hideProgress()

            self.writer?.deleteFile()
            if let error = error {
                log("FirebaseUpload: Error \(error.localizedDescription)")

                self.showAlert(
                    title: "Nepodařilo se nám odeslat data",
                    message: "Zkontrolujte připojení k internetu a zkuste to znovu"
                )
                return
            }
            AppSettings.lastUploadDate = fileDate
            self.performSegue(withIdentifier: "sendReport", sender: nil)
        }
    }

}
