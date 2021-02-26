//
//  HelpService.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import Foundation
import FirebaseCrashlytics
import SwiftyMarkdown

protocol HasHelpService {
    var help: HelpServicing { get }
}

protocol HelpServicing {

    var help: Help { get }

    var lineProcessor: SwiftyLineProcessor { get }

    func update()

}

class HelpService: HelpServicing {

    private(set) var help: Help = []

    var lineProcessor: SwiftyLineProcessor {
        let lineProcessor = SwiftyLineProcessor(
            rules: SwiftyMarkdown.lineRules,
            defaultRule: MarkdownLineStyle.body,
            frontMatterRules: SwiftyMarkdown.frontMatterRules
        )
        lineProcessor.processEmptyStrings = MarkdownLineStyle.body
        return lineProcessor
    }

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
