//
//  HelpService.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

protocol HelpServicing {

    var help: Help { get }

    func update()

}

class HelpService: HelpServicing {

    private(set) var help: Help = []

    func update() {
        let data = RemoteValues.helpJson
        let decoder = JSONDecoder()

        do {
            let help = try decoder.decode(Help.self, from: data)
            self.help = help
        } catch {
            Crashlytics.crashlytics().record(error: error)
        }
    }

}
