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
        let current = scannerStore.currentScan
            .map { unsortedScans in
                return unsortedScans.sorted(by: { scan0, scan1 in scan0.buid < scan1.buid })
            }
            .map { [unowned self] scans -> [SectionModel] in
                return self.section(from: scans, for: .current)
            }
        let log = scannerStore.scans
            .map { unsortedScans in
                return unsortedScans.sorted(by: { scan0, scan1 in scan0.date > scan1.date })
            }
            .map { [unowned self] scans -> [SectionModel] in
                return self.section(from: scans, for: .log)
            }
        return Observable.combineLatest(current.startWith([]), log.startWith([])) { currentSection, logSection -> [SectionModel] in
                return currentSection + logSection
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    // MARK: - Clear stored records
    
    func clear() {
        scannerStore.clear()
    }
}

// MARK: - Sections helpers

extension ScanListVM {

    private func section(from scans: [DeviceScan], for section: Section) -> [SectionModel] {
        let items: [ScanListVM.Section.Item] = scans.map { .scan($0) }
        return [SectionModel(model: section, items: items)]
    }
}

// MARK: - Sections

extension ScanListVM {
    
    typealias SectionModel = AnimatableSectionModel<Section, Section.Item>

    enum Section: IdentifiableType, Equatable {
        case current
        case log
        
        var identity: String {
            switch self {
            case .current: return "Current"
            case .log: return "History"
            }
        }
        
        static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.identity == rhs.identity
        }
        
        enum Item: IdentifiableType, Equatable {
            case scan(DeviceScan)

            var identity: String {
                switch self {
                case .scan(let scan):
                    return scan.id
                }
            }

            var rsii: Int {
                switch self {
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
