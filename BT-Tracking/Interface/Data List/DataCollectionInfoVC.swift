//
//  DataCollectionInfoVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 16/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

final class DataCollectionInfoVC: MarkdownController {

    override var markdownContent: String {
        RemoteValues.dataCollectionMarkdown
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle("data_list_info_button")
        navigationItem.largeTitleDisplayMode = .never
    }

}
