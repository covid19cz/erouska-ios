//
//  HelpEntities.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import Foundation
import SwiftyMarkdown

struct HelpSection: Codable {
    let title: String
    let subtitle: String
    let icon: String
    let questions: [HelpQuestion]
}

struct HelpQuestion: Codable {
    let question: String
    let answer: String

    var lines: [SwiftyLine] {
        AppDelegate.dependency.lineProcessor.process(answer)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.question == rhs.question
    }
}

typealias Help = [HelpSection]
