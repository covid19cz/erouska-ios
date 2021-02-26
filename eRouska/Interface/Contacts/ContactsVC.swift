//
//  ContactsVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 24/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ContactsVC: BaseController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasDiagnosis

    var dependencies: Dependencies!

    // MARK: -

    private let viewModel = ContactsVM()

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: -

    override func awakeFromNib() {
        super.awakeFromNib()

        navigationController?.tabBarItem.tag = MainTab.contacts.rawValue
        navigationController?.tabBarItem.title = L10n.contactsTitle
        navigationController?.tabBarItem.image = Asset.contacts.image
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.contactsTitle

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 210
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: - Actions

    private func openLink(_ link: URL) {
        if link.absoluteString.hasSuffix("info@erouska.cz"), dependencies.diagnosis.canSendMail {
            dependencies.diagnosis.present(fromController: self, screenName: .contact, kind: .error(nil))
        } else {
            openURL(URL: link)
        }
    }

}

extension ContactsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactCell
        cell?.config(with: viewModel.contacts[indexPath.row])
        cell?.openLinkClosure = { [weak self] in
            self?.openLink($0)
        }
        return cell ?? UITableViewCell()
    }
}
