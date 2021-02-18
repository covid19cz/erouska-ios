//
//  DownloadReportsVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 02/11/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxDataSources

final class DownloadReportsVC: UITableViewController {

    typealias Section = SectionModel<String, String>
    private var sections: BehaviorRelay<[Section]>

    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<Section>!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        sections = BehaviorRelay(value: [])

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setupDataSource()
    }

    required init?(coder: NSCoder) {
        sections = BehaviorRelay(value: [])

        super.init(coder: coder)

        setupDataSource()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.debug + " zkontrolovat reporty"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))
        tableView.dataSource = nil
        tableView.delegate = nil

        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        downloadKeys()
    }

    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<Section>(configureCell: { [weak self] _, _, _, item in
            self?.configureCell(item) ?? UITableViewCell()
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionModels[index].model
        }
    }

    private func configureCell(_ item: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "debugCell") ?? UITableViewCell()
        cell.textLabel?.text = item
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - Actions

    @IBAction private func closeAction() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Download

    private func downloadKeys() {
        showProgress()

        let keyURLs = AppSettings.efgsEnabled ? RemoteValues.keyExportEuTravellerUrls : RemoteValues.keyExportNonTravellerUrls
        AppDelegate.dependency.reporter.downloadKeys(exportURLs: keyURLs, lastProcessedFileNames: [:]) { [weak self] report in
            self?.processKeys(report)
        }
    }

    private func processKeys(_ report: ReportDownload) {
        let dispatchGroup = DispatchGroup()
        let configuration = RemoteValues.exposureConfiguration
        let exposureService = AppDelegate.dependency.exposure

        var resultText: String = ""

        var sections: [Section] = []

        var URLs: [URL] = []
        for (code, success) in report.success {
            sections.append(.init(model: code, items: ["Downloaded files: \(success.URLs.count / 2)"]))

            guard !success.URLs.isEmpty else {
                continue
            }
            URLs.append(contentsOf: success.URLs)
        }

        for (code, failure) in report.failures {
            log("EXP: failed to download keys for country \(code), error: \(failure)")
            sections.append(.init(model: code, items: ["Failed to download index: \(failure)"]))
        }

        dispatchGroup.enter()
        exposureService.detectExposures(configuration: configuration, URLs: URLs) { result in
            var rows: [String] = []

            switch result {
            case .success(let exposures):
                guard !exposures.isEmpty else {
                    rows.append("No exposures.")
                    break
                }

                try? ExposureList.add(exposures, detectionDate: Date())

                for exposure in exposures {
                    let signals = exposure.attenuationDurations.map { "\($0)" }
                    let exposureResult = "\(DateFormatter.baseDateTimeFormatter.string(from: exposure.date))" +
                        ", dur: \(exposure.duration), risk \(exposure.totalRiskScore), tran level: \(exposure.transmissionRiskLevel)\n"
                        + "attenuation value: \(exposure.attenuationValue)\n"
                        + "signal attenuations: \(signals.joined(separator: ", "))\n"
                    resultText += "EXP: " + exposureResult
                    rows.append(exposureResult)
                }

                if resultText.isEmpty {
                    resultText += "None"
                }
                log("EXP: \(exposures)")
            case .failure(let error):
                resultText += "Error: \(error)"

                rows.append("Failed to detect exposures: \(error)")
            }

            sections.append(.init(model: "DOWNLOADED KEYS", items: rows))
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            log("EXP: \(resultText)")
            self?.sections.accept(sections)
            self?.hideProgress()
        }

        if report.success.isEmpty {
            self.hideProgress()
        }
    }

}
