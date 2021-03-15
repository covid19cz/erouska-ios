//
//  HowItWorksVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 30.12.2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HowItWorksVC: BaseTableViewController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasDiagnosis

    var dependencies: Dependencies!

    // MARK: -

    private let viewModel = HowItWorksVM()

    private var isModal: Bool {
        navigationController?.viewControllers.first == self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.howitworksTitle
        tableView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isModal {
            setupCloseButton(#selector(closeAction))
        }
    }

    // MARK: - Actions

    @IBAction private func mailAction() {
        if dependencies.diagnosis.canSendMail {
            dependencies.diagnosis.present(fromController: self, screenName: .howItWorks, kind: .error(nil))
        } else if let URL = URL(string: "mailto:info@erouska.cz") {
            openURL(URL: URL)
        }
    }

    @IBAction private func closeAction() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.entries.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= viewModel.entries.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "howItWorksButtons") as? HowItWorksButtonsCell
            cell?.config(
                with: L10n.howitworksMailSupport,
                actionClosure: { [weak self] in
                    self?.mailAction()
                },
                closeTitle: isModal ? L10n.howitworksClose : nil, closeClosure: { [weak self] in
                    self?.closeAction()
                }
            )
            return cell ?? UITableViewCell()
        }
        let entry = viewModel.entries[indexPath.row]

        if let title = entry.title, let icon = entry.icon {
            let cell = tableView.dequeueReusableCell(withIdentifier: "howItWorksEntry") as? HowItWorksEntryCell
            cell?.config(with: title, body: entry.body, icon: icon)
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "howItWorksText")
            cell?.textLabel?.text = entry.body
            return cell ?? UITableViewCell()
        }
    }

}
