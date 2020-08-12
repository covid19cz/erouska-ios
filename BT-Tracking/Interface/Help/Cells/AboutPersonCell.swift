//
//  AboutPersonCell.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 21/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import AlamofireImage

final class AboutPersonCell: UITableViewCell {

    static let identifier = "personCell"

    @IBOutlet private weak var avatarView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        avatarView.layer.masksToBounds = true
        avatarView.layer.cornerRadius = 3
        if #available(iOS 13.0, *) {
            avatarView.backgroundColor = .systemGray6
        } else {
            avatarView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarView.image = nil
    }

    func configure(name: String, avatar: String?) {
        if let rawURL = avatar, let URL = URL(string: rawURL) {
            avatarView.af.setImage(withURL: URL)
        }
        nameLabel.text = name
    }

}
