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

    typealias Section = SectionModel<String, HelpSection>
    let sections = BehaviorRelay<[Section]>(value: [])

    private let helpService: HelpServicing

    init(helpService: HelpServicing) {
        self.helpService = helpService
        update()
    }

    func update() {
        helpService.update()

        var help = helpService.help
        help.insert(
            HelpSection(
                title: L10n.howitworksTitle,
                subtitle: L10n.howitworksSubtitle,
                icon: "",
                image: Asset.hitWIconSmall.image,
                questions: []
            ),
            at: 0
        )
        help.append(
            HelpSection(
                title: L10n.about,
                subtitle: "",
                icon: "",
                image: Asset.about.image,
                questions: []
            )
        )

        sections.accept([.init(model: "", items: help)])
    }

}
