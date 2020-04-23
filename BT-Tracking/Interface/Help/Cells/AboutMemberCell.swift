//
//  AboutPerson.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 21/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class AboutPerson: UITableViewCell {

    @IBOutlet private weak var avatarView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        avatarView.layer.masksToBounds = true
        avatarView.layer.cornerRadius = 2
    }

    func setup(name: String, avatar: UIImage?) {
        avatarView.image = avatar
        nameLabel.text = name
    }

}
