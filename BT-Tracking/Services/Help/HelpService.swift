//
//  HelpService.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import Foundation

protocol HelpServicing {

    var help: Help { get }

    func load()

}

class HelpService: HelpServicing {

    private(set) var help: Help = []

    func load() {
        let data = RemoteValues.helpJson
        let decoder = JSONDecoder()

        guard let help = try? decoder.decode(Help.self, from: data) else { return }
        self.help = help
    }

}
