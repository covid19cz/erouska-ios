//
//  CurrentDataVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 25/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import Reachability

final class CurrentDataVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var footerLabel: UILabel!

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!

    private let viewModel = CurrentDataVM()
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        title = L10n.dataListTitle
        tabBarItem.title = L10n.dataListTitle
        tabBarItem.image = Asset.myData.image
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        headlineLabel.text = L10n.errorUnknownHeadline
        textLabel.text = L10n.errorUnknownText
        actionButton.setTitle(L10n.errorUnknownTitleRefresh)

        scrollView.alpha = 0
        buttonsView.alpha = 0

        viewModel.needToUpdateView.subscribe(onNext: { [weak self] in
            self?.hideProgress(fromView: true)
            self?.showError(show: false)
            self?.tableView.reloadData()
            self?.footerLabel.text = self?.viewModel.footer
        }).disposed(by: disposeBag)

        viewModel.observableErrors.subscribe(onNext: { [weak self] error in
            guard error != nil else { return }

            self?.hideProgress(fromView: true)

            // Don't show error when internet connection is not available
            if let connection = try? Reachability().connection, connection == .unavailable {
                self?.showError(show: false)
                self?.tableView.reloadData()
                self?.footerLabel.text = self?.viewModel.footer
                return
            }

            self?.showError(show: true)
        }).disposed(by: disposeBag)

        footerLabel.text = viewModel.footer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.fetchCurrentDataIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.sections.isEmpty ? showProgress(fromView: true) : hideProgress(fromView: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let footer = tableView.tableFooterView {
            footer.frame.size.height = footer.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0)).height
        }
    }

    // MARK: - Actions

    @IBAction private func toRefresh(_ sender: Any) {
        viewModel.fetchCurrentDataIfNeeded()
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

        let cell = tableView.dequeueReusableCell(withIdentifier: item.subtitle == nil ? "BasicCell" : "SubtitleCell") ?? UITableViewCell()

        cell.imageView?.image = item.iconAsset.image
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

        guard indexPath.section == 0, let measuresURL = viewModel.measuresURL else { return }
        openURL(URL: measuresURL)
    }

}

private extension CurrentDataVC {

    func showError(show: Bool, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.25 : 0, delay: 0, options: .curveEaseInOut) {
            if show {
                self.tableView.alpha = 0

                self.scrollView.alpha = 1
                self.buttonsView.alpha = 1
            } else {
                self.tableView.alpha = 1

                self.scrollView.alpha = 0
                self.buttonsView.alpha = 0
            }
        }
    }

}
