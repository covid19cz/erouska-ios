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
import FirebaseAuth
import FirebaseStorage

final class DataListVC: UIViewController, UITableViewDelegate {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityView: UIView!

    private var dataSource: RxTableViewSectionedAnimatedDataSource<DataListVM.SectionModel>!
    private let viewModel = DataListVM()
    private let bag = DisposeBag()

    private var writer: CSVMakering?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *) {
            navigationController?.tabBarItem.image = UIImage(systemName: "doc.plaintext")
        } else {
            navigationController?.tabBarItem.image = UIImage(named: "doc.plaintext")?.resize(toWidth: 20)
        }
        
        setupTableView()
    }

    // MARK: - TableView

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension

        dataSource = RxTableViewSectionedAnimatedDataSource<DataListVM.SectionModel>(configureCell: { datasource, tableView, indexPath, row in
            let cell: UITableViewCell?
            switch row {
            case .header(let scansCount):
                let headerCell = tableView.dequeueReusableCell(withIdentifier: DataHeaderCell.identifier, for: indexPath) as? DataHeaderCell
                headerCell?.configure(with: scansCount)
                cell = headerCell
            case .data(let scan):
                let scanCell = tableView.dequeueReusableCell(withIdentifier: DataCell.identifier, for: indexPath) as? DataCell
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

    // MARK: - Actions
    @IBAction private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.onSegmentedControl.onNext(sender.selectedSegmentIndex)
    }

    @IBAction private func sendReportAction() {
        let controller = UIAlertController(
            title: "Byli jste požádáni o odeslání seznamu telefonů, se kterými jste se setkali?",
            message: "",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Ano, odeslat", style: .default, handler: { _ in
            self.sendReport()
        }))
        controller.addAction(UIAlertAction(title: "Ne", style: .cancel, handler: { _ in
            self.showError(
                title: "Sdílejte data jen v případě, že vás o to poprosí hygienik a vyzve vás k zaslání dat. To se stane jen v případě, že budete v okruhu lidí nakažených koronavirem.",
                message: ""
            )
        }))
        controller.preferredAction = controller.actions.first
        present(controller, animated: true, completion: nil)
    }

    @IBAction private func infoButtonAction() {
        let controller = UIAlertController(
            title: "Jedná se veškeré záznamy o měření signálu okolních telefonů s aplikací eRouška za posledních 14 dní. Data neobsahují údaje o poloze ani jiné osobní údaje. Odeslat hygienikům je můžete pouze vy.",
            message: nil,
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "Zavřít", style: .default, handler: nil))

        present(controller, animated: true, completion: nil)
    }

    private func sendReport() {
        guard (AppSettings.lastUploadDate ?? Date.distantPast) + (15 * 60) < Date() else {
            showError(
                title: "Data jsme už odeslali. Prosím počkejte 15 minut a pošlete je znovu.",
                message: ""
            )
            return
        }

        activityView.isHidden = false
        createCSVFile()
    }

    private func createCSVFile() {
        let fileDate = Date()

        writer = CSVMaker(fromDate: AppSettings.lastUploadDate)
        writer?.createFile(callback: { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                self.uploadCSVFile(fileURL: result.fileURL, metadata: result.metadata, fileDate: fileDate)
            } else if let error = error {
                self.activityView.isHidden = true
                self.show(error: error, title: "Nepodařilo se vytvořit soubor se setkánímy")
            }
        })
    }

    private func uploadCSVFile(fileURL: URL, metadata: [String: String], fileDate: Date) {
        let path = "proximity/\(Auth.auth().currentUser?.uid ?? "")/\(AppSettings.BUID ?? "")"
        let fileName = "\(Int(fileDate.timeIntervalSince1970 * 1000)).csv"

        let storage = Storage.storage()
        let storageReference = storage.reference()
        let fileReference = storageReference.child("\(path)/\(fileName)")
        let storageMetadata = StorageMetadata()
        storageMetadata.customMetadata = metadata

        fileReference.putFile(from: fileURL, metadata: storageMetadata) { (metadata, error) in
            self.activityView.isHidden = true

            if let error = error {
                self.show(error: error, title: "Nepodařilo se nahrát setkání")
                return
            }
            AppSettings.lastUploadDate = fileDate
            self.performSegue(withIdentifier: "sendReport", sender: nil)
        }
    }

}
