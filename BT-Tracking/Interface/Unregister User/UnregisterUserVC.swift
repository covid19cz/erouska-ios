//
//  UnregisterUserVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 30/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

protocol UnregisterUserVCDelegate: AnyObject {
    func controllerDidTapConfirm(_ controller: UnregisterUserVC)
    func controllerDidTapHelp(_ controller: UnregisterUserVC)
}

final class UnregisterUserVC: UIViewController {

    weak var delegate: UnregisterUserVCDelegate?
    var phoneNumber: String?

    @IBOutlet private weak var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Nápověda", style: .plain, target: self, action: #selector(didTapHelp))

        // TODO: msrutek, inject P/N
        textLabel.text = textLabel.text?.replacingOccurrences(of: "%@", with: phoneNumber?.phoneFormatted ?? "")
    }

    // MARK: - Actions

    @IBAction private func didTapConfirm() {
        delegate?.controllerDidTapConfirm(self)
    }

    @objc private func didTapHelp() {
        delegate?.controllerDidTapHelp(self)
    }
}
