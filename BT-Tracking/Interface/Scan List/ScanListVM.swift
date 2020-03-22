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
    
    // MARK: - Properties
    
    private let scannerStore: ScannerStore
    
    // MARK: - Init
    
    init(scannerStore: ScannerStore) {
        self.scannerStore = scannerStore
    }
    
    // MARK: - Sections
    
    var sections: Driver<[SectionModel]> {
        return scannerStore.scans
            .map { unsortedScans in
                return unsortedScans.sorted(by: { scan0, scan1 in scan0.date > scan1.date })
            }
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
        return [
            SectionModel(model: .info, items: [Section.Item.info(UserDefaults.standard.string(forKey: "BUID"))]),
            SectionModel(model: .scans, items: items)
        ]
    }

}

// MARK: - Sections

extension ScanListVM {
    
    typealias SectionModel = AnimatableSectionModel<Section, Section.Item>

    enum Section: IdentifiableType, Equatable {
        case info
        case scans
        
        var identity: String {
            switch self {
            case .info:
                return "info"
            case .scans:
                return "scans"
            }
        }
        
        static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.identity == rhs.identity
        }
        
        enum Item: IdentifiableType, Equatable {
            case info(_ buid: String?)
            case scan(Scan)

            var identity: String {
                switch self {
                case .info:
                    return "buid"
                case .scan(let scan):
                    return scan.id.uuidString
                }
            }

            var rsii: Int? {
                switch self {
                case .info:
                    return nil
                case .scan(let scan):
                    return scan.rssi
                }
            }
            
            static func == (lhs: Item, rhs: Item) -> Bool {
                return lhs.identity == rhs.identity && lhs.rsii == rhs.rsii
            }
        }
    }

}
