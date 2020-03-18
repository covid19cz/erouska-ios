//
//  ScanListVM.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class ScanListVM {
    
    // MARK: - Sections
    
    var sections: Driver<[SectionModel]> {
        return Observable.just([
                Scan(identifier: "1234-5678-ABCDE-FGHI", name: "BTLE device", date: Date(), rssi: -69),
                Scan(identifier: "4321-5678-ABCDE-FGHI", name: "XX device", date: Date(), rssi: -69),
                Scan(identifier: "4983-5678-ABCDE-FGHI", name: "ZZ device", date: Date() - 1234, rssi: -77),
                Scan(identifier: "2343-5678-ABCDE-FGHI", name: "FF device", date: Date() - 23456, rssi: -44)
            ])
            .map { [unowned self] scans -> [SectionModel] in
                return self.section(from: scans)
            }
            .asDriver(onErrorJustReturn: [])
    }
}

// MARK: - Sections helpers

extension ScanListVM {

    private func section(from scans: [Scan]) -> [SectionModel] {
        let items: [ScanListVM.Section.Item] = scans.map { .scan($0) }
        return [SectionModel(model: .scans, items: items)]
    }
}

// MARK: - Sections

extension ScanListVM {
    
    typealias SectionModel = AnimatableSectionModel<Section, Section.Item>

    enum Section: IdentifiableType, Equatable {
        case scans
        
        var identity: String {
            switch self {
            case .scans: return "scans"
            }
        }
        
        static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.identity == rhs.identity
        }
        
        enum Item: IdentifiableType, Equatable {
            case scan(Scan)

            var identity: String {
                switch self {
                case .scan(let scan): return scan.id
                }
            }
            
            static func == (lhs: Item, rhs: Item) -> Bool {
                return lhs.identity == rhs.identity
            }
        }
    }
}
