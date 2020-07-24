//
//  DataListVC.swift
// eRouska
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

        AppDelegate.dependency.reporter.fetchExposureConfiguration { [weak self] result in
            switch result {
            case .success(let configuration):
                AppDelegate.dependency.reporter.downloadKeys { [weak self] result in
                    switch result {
                    case .success(let URLs):
                        AppDelegate.dependency.exposureService.detectExposures(
                            configuration: configuration,
                            URLs: URLs
                        ) { [weak self] result in
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
                                self?.showAlert(title: "Exposures", message: result)
                            case .failure(let error):
                                self?.hideProgress()
                                self?.showDownloadDataErrorFailed(error)
                            }
                        }
                    case .failure(let error):
                        self?.hideProgress()
                        self?.showDownloadDataErrorFailed(error)
                    }
                }
            case .failure(let error):
                self?.hideProgress()
                self?.showDownloadDataErrorFailed(error)
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

    // MARK: - Reports

    enum ReportType {
        case real, test
    }

    func sendReport() {
        let controller = UIAlertController(title: "Ktery druh klicu?", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Test keys", style: .default, handler: { _ in
            self.sendReport(with: .test)
        }))
        controller.addAction(UIAlertAction(title: "Keys", style: .default, handler: { _ in
            self.sendReport(with: .real)
        }))
        controller.addAction(UIAlertAction(title: "Zrusit", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    func sendReport(with type: ReportType) {
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

        showProgress()

        let exposureService = AppDelegate.dependency.exposureService
        let callback: ExposureServicing.KeysCallback = { result in
            switch result {
            case .success(let keys):
                AppDelegate.dependency.reporter.uploadKeys(keys: keys, callback: { [weak self] result in
                    self?.hideProgress()
                    switch result {
                    case .success:
                        self?.performSegue(withIdentifier: "sendReport", sender: nil)
                    case .failure:
                        self?.showSendDataErrorFailed()
                    }
                })
            case .failure(let error):
                log("DataListVC: Failed to get exposure keys \(error)")
                self.hideProgress()
                self.showSendDataErrorFailed()
            }
        }

        switch type {
        case .test:
            exposureService.getTestDiagnosisKeys(callback: callback)
        case .real:
            exposureService.getDiagnosisKeys(callback: callback)
        }
    }

    func showDownloadDataErrorFailed(_ error: Error) {
        show(error: error)
    }

    func showSendDataErrorFailed() {
        showAlert(
            title: viewModel.sendDataErrorFailedTitle,
            message: viewModel.sendDataErrorFailedMessage
        )
    }

}
