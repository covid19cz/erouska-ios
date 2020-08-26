//
//  CurrentDataVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 25/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift

final class CurrentDataVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerLabel: UILabel!

    private let viewModel = CurrentDataVM()
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        navigationController?.tabBarItem.localizedTitle(viewModel.tabTitle)
        navigationController?.tabBarItem.image = viewModel.tabIcon
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.needToUpdateView.subscribe(onNext: { [weak self] in
            self?.hideProgress()
            self?.tableView.reloadData()
            self?.footerLabel.text = self?.viewModel.footer
        }).disposed(by: disposeBag)

        viewModel.obervableErrors.subscribe(onNext: { [weak self] error in
            self?.hideProgress()
            #if DEBUG
            if let error = error {
                self?.show(error: error)
            }
            #endif
        }).disposed(by: disposeBag)

        footerLabel.text = viewModel.footer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.fetchCurrentDataIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.sections.isEmpty {
            showProgress()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let footer = tableView.tableFooterView {
            footer.frame.size.height = footer.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0)).height
        }
    }
}

extension CurrentDataVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.sections[indexPath.section]
        let item = section.items[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: item.subtitle == nil ? "BasicCell" : "SubtitleCell")!

        cell.imageView?.image = UIImage(named: item.iconName)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        cell.selectionStyle = section.selectableItems ? .default : .none
        cell.accessoryType = section.selectableItems ? .disclosureIndicator : .none

        return cell
    }
}

extension CurrentDataVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerTitle = viewModel.sections[section].header {
            let header = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")
            header?.textLabel?.text = headerTitle
            header?.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
            header?.textLabel?.textColor = .secondaryLabel
            return header
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.sections[section].header == nil ? 0 : 40
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.section == 0 else { return }
        openURL(URL: viewModel.measuresURL)
    }
}
