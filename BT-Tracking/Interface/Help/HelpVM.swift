//
//  HelpVM.swift
//  BT-Tracking
//
//  Created by Bogdan Kurpakov on 30/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import RxRealm
import RealmSwift

class HelpVM {

    struct HelpData {
        let title: String
        let description: String
    }

    var notes: [HelpData] = []

    init() {
        notes = [
            HelpData(title: "Aplikace pomocí technologie Bluetooth sleduje telefony, které se pohybují ve vašem okolí a také mají aplikaci nainstalovanou", description: "Následně zaznamená ID aplikací a bez vašeho souhlasu je nikam nezasílá."),
            HelpData(title: "K odeslání dat z aplikací dojde pouze v případě, že budete mít podezření na nákazu koronavirem", description: "Data odesílejte až v momentě, kdy vás kontaktují vás hygienici."),
            HelpData(title: "Co se děje s údaji o telefonech na seznamu osob, které jsem potkal", description: "Data jsou po celou dobu uchovávána ve vašem telefonu a nikam je neodesíláme. K odeslání dat dojde až ve chvíli, kdy  to bude nutné. Nejprve vás bude kontaktovat pracovník hygienické stanice a požádá vás k odeslání dat."),
            HelpData(title: "Kdo aplikaci provozuje", description: "Aplikaci provozují dobrovolníci z několika českých firem pod záštitou a dohledem Ministerstva zdravotnictví České republiky.")
        ]
    }

    var sections: Driver<[SectionModel]> {
        let items = notes.map { HelpVM.Section.Item.main($0) }
        return Driver.just([SectionModel(model: .list, items: items)])
    }
}

extension HelpVM {

    typealias SectionModel = AnimatableSectionModel<Section, Section.Item>

    enum Section: IdentifiableType, Equatable {
        case list

        var identity: String {
            switch self {
            case .list:
                return "list"
            }
        }

        static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.identity == rhs.identity
        }

        enum Item: IdentifiableType, Equatable {
            case main(HelpData)

            var identity: String {
                switch self {
                case .main(let data):
                    return data.title
                }
            }

            static func == (lhs: Item, rhs: Item) -> Bool {
                return lhs.identity == rhs.identity
            }
        }
    }
}
