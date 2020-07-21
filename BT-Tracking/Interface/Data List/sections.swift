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
import BackgroundTasks

final class DataListVC: UIViewController, UITableViewDelegate {

    // MARK: -

    private var dataSource: RxTableViewSectionedAnimatedDataSource<DataListVM.SectionModel>!
    private let viewModel = DataListVM()
    private let bag = DisposeBag()

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

    @IBAction private func processReports() {
        showProgress()

        let dateFormat = DateFormatter()
        dateFormat.timeStyle = .short
        dateFormat.dateStyle = .short

        AppDelegate.dependency.exposureService.detectExposures { result in
            self.hideProgress()

            switch result {
            case .success(var exposures):
                exposures.sort { $0.date < $1.date }

                var result = ""
                for exposure in exposures {
                    let signals = exposure.attenuationDurations.map { "\($0)" }
                    result += "EXP: \(dateFormat.string(from: exposure.date))" +
                    ", dur: \(exposure.duration), risk \(exposure.totalRiskScore), tran level: \(exposure.transmissionRiskLevel)\n"
                        + "attenuation value: \(exposure.attenuationValue)\n"
                        + "signal attenuations: \(signals.joined(separator: ", "))\n"
                }
                if result == "" {
                    result = "None";
                }

                log("EXP: \(exposures)")
                log("EXP: \(result)")
                self.showAlert(title: "Exposures", message: result)
            case .failure(let error):
                self.show(error: error)
            }
        }
    }

    @IBAction private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.selectedSegmentIndex.accept(sender.selectedSegmentIndex)
    }

    @IBAction private func sendReportAction(_ sender: Any?) {
        let controller = UIAlertController(
            title: Localizable(viewModel.sendDataQuestionTitle),
            message: Localizable(viewModel.sendDataQuestionMessage),
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(
            title: Localizable(viewModel.sendDataQuestionYes),
            style: .default,
            handler: { [weak self] _ in
                guard let self = self else { return }
                self.sendReport()
            }
        ))
        controller.addAction(UIAlertAction(
            title: Localizable(viewModel.sendDataQuestionNo),
            style: .cancel,
            handler: { [weak self] _ in
                guard let self = self else { return }
                self.showAlert(title: self.viewModel.sendDataErrorOnlyAfter)
            }
        ))
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

    // MARK: - Report

    func sendReport() {
        let alert = UIAlertController(title: "Ktery druh klicu", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Test keys", style: .default, handler: { _ in
            self.newSendReport()
        }))
        alert.addAction(UIAlertAction(title: "Zrusit", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func newSendReport() {
        #if DEBUG
        #else
        guard (AppSettings.lastUploadDate ?? Date.distantPast) + RemoteValues.uploadWaitingMinutes < Date() else {
            showAlert(title: viewModel.sendDataErrorWait)
            return
        }
        #endif

        guard let connection = try? Reachability().connection, connection != .unavailable else {
            showSendDataErrorFailed()
            return
        }

        let exposureService = AppDelegate.dependency.exposureService
        let callback: ExposureServicing.KeysCallback = { result in
            switch result {
            case .success(let keys):
                let encoder = JSONEncoder()
                let data = (try? encoder.encode(keys)) ?? Data()

                let path = "exposure/\(Auth.auth().currentUser?.uid ?? "")/"
                let fileName = "exposure.json"

                let storage = Storage.storage()
                let storageReference = storage.reference()
                let fileReference = storageReference.child("\(path)/\(fileName)")
                let storageMetadata = StorageMetadata()
                let metadata = [
                    "version": "1",
                    "buid": KeychainService.BUID ?? ""
                ]
                storageMetadata.customMetadata = metadata

                fileReference.putData(data, metadata: storageMetadata) { [weak self] (metadata, error) in
                    guard let self = self else { return }
                    self.hideProgress()

                    if let error = error {
                        log("FirebaseUpload: Error \(error.localizedDescription)")
                        self.showSendDataErrorFailed()
                        return
                    }
                    AppSettings.lastUploadDate = Date()
                    self.performSegue(withIdentifier: "sendReport", sender: nil)
                }
            case .failure(let error):
                log("Failed to get exposure keys \(error)")
            }
        }

        #if DEBUG
        exposureService.getTestDiagnosisKeys(callback: callback)
        #else
        exposureService.getDiagnosisKeys(callback: callback)
        #endif
    }

    func showSendDataErrorFailed() {
        showAlert(
            title: viewModel.sendDataErrorFailedTitle,
            message: viewModel.sendDataErrorFailedMessage
        )
    }

}
