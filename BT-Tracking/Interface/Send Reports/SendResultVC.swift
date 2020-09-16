//
//  SendResultVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class SendResultVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var closeButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle("data_send_title")
        navigationItem.hidesBackButton = true

        titleLabel.localizedText("data_send_title_label")
        headlineLabel.localizedText("data_send_headline")
        bodyLabel.localizedText("data_send_body")
        closeButton.localizedTitle("data_send_close_button")
    }

    // MARK: - Action

    @IBAction private func closeAction() {
        dismiss(animated: true, completion: nil)
    }

}
