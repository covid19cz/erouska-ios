//
//  PreviousRiskyEncountersVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxRealm
import RxDataSources

final class PreviousRiskyEncountersVC: BaseController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasExposureList

    var dependencies: Dependencies!

    // MARK: -

    @IBOutlet private weak var tableView: UITableView!

    private var viewModel: PreviousRiskyEncountersVM!
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<PreviousRiskyEncountersVM.Section>!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        dataSource = nil

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        viewModel = PreviousRiskyEncountersVM(dependencies: dependencies)
        setupDataSource()
    }

    required init?(coder: NSCoder) {
        dataSource = nil

        super.init(coder: coder)

        viewModel = PreviousRiskyEncountersVM(dependencies: dependencies)
        setupDataSource()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(Exposure.self)
            .subscribe(onNext: { [weak self] value in
                #if DEBUG || !PROD
                if let indexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }

                if let value = value.window {
                    self?.perform(segue: StoryboardSegue.RiskyEncounters.showDetailV2, sender: value)
                } else {
                    self?.perform(segue: StoryboardSegue.RiskyEncounters.showDetailV1, sender: value)
                }
                #endif
            })
            .disposed(by: disposeBag)

        tableView.tableFooterView = UIView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch StoryboardSegue.RiskyEncounters(segue) {
        case .showDetailV1:
            let controller = segue.destination as? RiskyEncountersV1DetailVC
            controller?.exposure = sender as? Exposure
        case .showDetailV2:
            let controller = segue.destination as? RiskyEncountersV2DetailVC
            controller?.exposure = sender as? ExposureWindow
        default:
            break
        }
    }

    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<PreviousRiskyEncountersVM.Section>(configureCell: { [weak self] _, _, _, item in
            self?.configureCell(item) ?? UITableViewCell()
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionModels[index].model
        }
    }

    private func configureCell(_ item: Exposure) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousRiskyEncountersCell") ?? UITableViewCell()
        cell.textLabel?.text = DateFormatter.baseDateFormatter.string(from: item.date)
        #if DEBUG || !PROD
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        #else
        cell.selectionStyle = .none
        cell.accessoryType = .none
        #endif
        return cell
    }

}
