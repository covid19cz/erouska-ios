//
//  HelpEntities.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 24.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import UIKit
import SwiftyMarkdown

struct HelpSection: Decodable {
    let title: String
    let subtitle: String
    let icon: String
    let image: UIImage?
    let questions: [HelpQuestion]

    enum CodingKeys: String, CodingKey {
        case title, subtitle, icon, questions
    }

    init(title: String, subtitle: String, icon: String, image: UIImage?, questions: [HelpQuestion]) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.image = image
        self.questions = questions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        icon = try container.decode(String.self, forKey: .icon)
        image = nil
        questions = try container.decode([HelpQuestion].self, forKey: .questions)
    }
}

struct HelpQuestion: Decodable {
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
