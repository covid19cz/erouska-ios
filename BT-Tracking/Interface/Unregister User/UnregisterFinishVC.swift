//
//  UnregisterFinishVC.swift
//  BT-Tracking
//
//  Created by Bogdan Kurpakov on 31/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

protocol UnregisterFinishVCDelegate: AnyObject {
    func controllerDidTapClose(_ controller: UnregisterFinishVC)
}

final class UnregisterFinishVC: UIViewController {

    weak var delegate: UnregisterFinishVCDelegate?

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: RoundedButtonFilled!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Registaci vašeho telefonního čísla jsme zrušili"
        closeButton.setTitle("Zavřít", for: .normal)
    }

    @IBAction func didTapClose(_ sender: Any) {
        delegate?.controllerDidTapClose(self)
    }
}
