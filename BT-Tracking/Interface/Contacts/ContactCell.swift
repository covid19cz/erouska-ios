//
//  ContactCell.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 19/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ContactCell: UITableViewCell {
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    private var contact: Contact? {
        didSet {
            headlineLabel.text = contact?.title
            bodyLabel.text = contact?.text
            button.setTitle(contact?.linkTitle, for: .normal)
        }
    }
    var openLinkClosure: ((URL) -> Void)?

    func config(with contact: Contact) {
        self.contact = contact
    }

    @IBAction func openLink() {
        guard let link = contact?.link else { return }
        openLinkClosure?(link)
    }
}
