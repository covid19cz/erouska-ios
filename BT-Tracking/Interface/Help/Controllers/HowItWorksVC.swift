//
//  HowItWorksVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 30.12.2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

struct HowItWorksEntry {

    let title: String?
    let body: String
    let icon: ImageAsset?

}

final class HowItWorksVC: UITableViewController {

    private var diagnosis: Diagnosis?

    private var entries: [HowItWorksEntry] = [
        .init(title: nil, body: L10n.howitworksHeadline, icon: nil),
        .init(title: L10n.HowitworksEntry1.title, body: L10n.HowitworksEntry1.body, icon: Asset.hitWPhones),
        .init(title: L10n.HowitworksEntry2.title, body: L10n.HowitworksEntry2.body, icon: Asset.hitWExposure),
        .init(title: L10n.HowitworksEntry3.title, body: L10n.HowitworksEntry3.body, icon: Asset.hItWNotifications),
        .init(title: L10n.HowitworksEntry4.title, body: L10n.HowitworksEntry4.body, icon: Asset.hitWCheck),
        .init(title: L10n.HowitworksEntry5.title, body: L10n.HowitworksEntry5.body, icon: Asset.hitWResult),
        .init(title: L10n.HowitworksEntry6.title, body: L10n.HowitworksEntry6.body, icon: Asset.hitWDisplay)
    ]

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
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))
        }
    }

    // MARK: - Actions

    @IBAction private func mailAction() {
        if Diagnosis.canSendMail {
            diagnosis = Diagnosis(showFromController: self, screenName: .howItWorks, kind: .error(nil))
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
        return entries.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= entries.count {
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
        let entry = entries[indexPath.row]

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
