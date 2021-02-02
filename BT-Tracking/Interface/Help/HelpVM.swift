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

        func addToSection(_ helpArticle: HelpArticle) {
            if RemoteValues.appleIgnoreAndroid {
                if !containesAndroid(helpArticle) {
                    section.items.append(helpArticle)
                }
            } else {
                section.items.append(helpArticle)
            }
        }

        for attribute in foundAttributes {
            guard let style = attribute.lineStyle as? MarkdownLineStyle else { continue }
            switch style {
            case .h1:
                if !section.model.isEmpty {
                    addToSection(helpArticle)
                    sections.append(section)
                    helpArticle = .init(title: "", lines: [])
                }
                section = .init(model: attribute.line, items: [])
            case .h2:
                if !helpArticle.lines.isEmpty {
                    addToSection(helpArticle)
                }
                helpArticle = HelpArticle(title: attribute.line, lines: [])
            default:
                helpArticle.lines.append(attribute)
            }
        }

        if !section.items.contains(helpArticle) {
            addToSection(helpArticle)
        }
        sections.append(section)

        self.sections.accept(sections)
    }

    private func containesAndroid(_ article: HelpArticle) -> Bool {
        if article.title.lowercased().contains("android") {
            return true
        } else if article.lines.contains(where: { $0.line.lowercased().contains("android") }) {
            return true
        }
        return false
    }

}
