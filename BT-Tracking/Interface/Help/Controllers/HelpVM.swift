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

final class HelpVM {

    private let lineProcessor = SwiftyLineProcessor(
        rules: SwiftyMarkdown.lineRules,
        defaultRule: MarkdownLineStyle.body,
        frontMatterRules: SwiftyMarkdown.frontMatterRules
    )

    typealias Section = SectionModel<HelpSection, HelpQuestion>
    let sections = BehaviorRelay<[Section]>(value: [])

    private let helpService: HelpServicing

    init(helpService: HelpServicing) {
        self.helpService = helpService
        update()
    }

    func update() {
        helpService.update()
        sections.accept(helpService.help.map { .init(model: $0, items: $0.questions) })
    }

}
