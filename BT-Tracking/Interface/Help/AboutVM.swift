//
//  AboutVM.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 21/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct AboutVM {

    let title = "about_title"

    let teams: [AboutTeam]

    var sections = BehaviorRelay<[SectionModel]>(value: [])

    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = RemoteValues.aboutJson.data(using: .utf8) ?? Data()
            teams = try decoder.decode([AboutTeam].self, from: data)

            let infoSection = SectionModel(
                model: .info,
                items: [Section.Item.info]
            )

            let teamSections = teams.map { team -> SectionModel in return self.section(from: team) }

            sections.accept([infoSection] + teamSections)
        } catch {
            teams = []
            print(error)
        }
    }

}

// MARK: - Sections

extension AboutVM {

    typealias SectionModel = AnimatableSectionModel<Section, Section.Item>

    private func section(from team: AboutTeam) -> SectionModel {
        let items: [Section.Item] = team.people.map { .person($0) }
        return SectionModel(model: .team(team), items: items)
    }

    enum Section: IdentifiableType, Equatable {
        case info
        case team(AboutTeam)

        var identity: String {
            switch self {
            case .info:
                return "info"
            case .team(let team):
                return "\(team.id)"
            }
        }

        static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.identity == rhs.identity
        }

        enum Item: IdentifiableType, Equatable {
            case info
            case person(AboutPerson)

            var identity: String {
                switch self {
                case .info:
                    return "info"
                case .person(let person):
                    return person.id.uuidString
                }
            }
            static func == (lhs: Item, rhs: Item) -> Bool {
                return lhs.identity == rhs.identity
            }
        }
    }

}
