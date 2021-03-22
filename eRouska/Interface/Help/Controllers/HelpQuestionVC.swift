//
//  HelpQuestionVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 21/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

import UIKit
import SwiftyMarkdown

final class HelpQuestionVC: MarkdownController {

    @IBOutlet private weak var stackView: UIStackView!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(contentView)
    }

}
