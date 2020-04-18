//
//  IntroController.swift
//  BT-Tracking
//
//  Created by Jakub Skořepa on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

protocol IntroControllerDelegate: AnyObject {
    func controllerDidTapContinue(_ controller: IntroController)
    func controllerDidTapHelp(_ controller: IntroController)
    func controllerDidTapAudit(_ controller: IntroController)
}

final class IntroController: UIViewController {

    // MARK: - Public Properties

    weak var delegate: IntroControllerDelegate?

    // MARK: - Private Properties

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
    }

    // MARK: - Actions

    @IBAction private func didTapHelp() {
        delegate?.controllerDidTapHelp(self)
    }
    
    @IBAction private func didTapContinue() {
        delegate?.controllerDidTapContinue(self)
    }
    
    @IBAction private func didTapAudit(_ sender: Any) {
        delegate?.controllerDidTapAudit(self)
    }

}
