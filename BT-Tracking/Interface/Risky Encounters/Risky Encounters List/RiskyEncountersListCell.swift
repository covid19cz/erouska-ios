//
//  RiskyEncountersListCell.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import AlamofireImage

final class RiskyEncountersListCell: UITableViewCell {
    @IBOutlet private weak var customImageView: UIImageView!
    @IBOutlet private weak var customTextLabel: UILabel!

    func config(with symptom: AsyncImageTitleViewModel) {
        customImageView.af.setImage(withURL: symptom.imageUrl, placeholderImage: nil) // TODO: add placeholder image
        customTextLabel.text = symptom.title
    }
}
