//
//  AboutVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 21/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class AboutVC: UIViewController {

    private let viewModel = AboutVM()

    // MARK: - Outlets

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle(viewModel.titleKey)

        textLabel.localizedText(viewModel.infoKey)

        tableView.tableFooterView = UIView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let header = tableView.tableHeaderView {
            header.frame.size.height = header.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0)).height
        }
    }
}

extension AboutVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")!
        cell.imageView?.image = UIImage(named: "ConditionsOfUse")
        cell.textLabel?.localizedText(viewModel.conditionsOfUseKey)
        return cell
    }
}

extension AboutVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let url = URL(string: viewModel.conditionsOfUseLink) else { return }
        openURL(URL: url)
    }
}

