//
//  HelpVM.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import SwiftyMarkdown
import RxSwift
import RxCocoa
import RxDataSources

struct HelpArticle: Equatable {
    let id = UUID()
    let title: String
    var lines: [SwiftyLine]

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

final class HelpVM {

    var chatbotLink: String {
        RemoteValues.chatBotLink
    }

    private let lineProcessor = SwiftyLineProcessor(
        rules: SwiftyMarkdown.lineRules,
        defaultRule: MarkdownLineStyle.body,
        frontMatterRules: SwiftyMarkdown.frontMatterRules
    )

    typealias Section = SectionModel<String, HelpArticle>
    let sections = BehaviorRelay<[Section]>(value: [])

    init() {
        update()
    }

    func update() {
        var convertedMarkdown = RemoteValues.helpMarkdown.replacingOccurrences(of: "\\n", with: "\u{0085}")
        convertedMarkdown = convertedMarkdown.replacingOccurrences(of: "(.pdf)", with: "")

        self.lineProcessor.processEmptyStrings = MarkdownLineStyle.body
        let foundAttributes: [SwiftyLine] = lineProcessor.process(convertedMarkdown)

        var sections: [Section] = []
        var section: Section = .init(model: "", items: [])
        var helpArticle: HelpArticle = .init(title: "", lines: [])

        for attribute in foundAttributes {
            guard let style = attribute.lineStyle as? MarkdownLineStyle else { continue }
            switch style {
            case .h1:
                if !section.items.isEmpty {
                    sections.append(section)
                }
                section = .init(model: attribute.line, items: [])
            case .h2:
                if !helpArticle.lines.isEmpty {
                    section.items.append(helpArticle)
                }
                helpArticle = HelpArticle(title: attribute.line, lines: [])
            default:
                helpArticle.lines.append(attribute)
            }
        }

        self.sections.accept(sections)
    }

}
