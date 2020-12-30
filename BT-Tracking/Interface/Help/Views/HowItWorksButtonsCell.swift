//
//  HowItWorksButtonsCell.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 30.12.2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class HowItWorksButtonsCell: UITableViewCell {

    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var closeButton: Button!

    private var actionClosure: CallbackVoid?
    private var closeClosure: CallbackVoid?

    func config(with actionTitle: String, actionClosure: CallbackVoid?, closeTitle: String, closeClosure: CallbackVoid?) {
        actionButton.setTitle(actionTitle)
        self.actionClosure = actionClosure
        closeButton.setTitle(closeTitle)
        self.closeClosure = closeClosure
    }

    @IBAction private func toAction() {
        actionClosure?()
    }

    @IBAction private func toClose() {
        closeClosure?()
    }

}
