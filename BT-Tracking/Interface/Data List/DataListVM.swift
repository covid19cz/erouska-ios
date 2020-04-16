//
//  DataListVM.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 23/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import RxRealm
import RealmSwift

final class DataListVM {

    // MARK: - Properties
    let selectedSegmentIndex = PublishRelay<Int>()

    private let scans: Observable<[Scan]>
    private let scanObjects: Results<ScanRealm>
    private let bag = DisposeBag()

    // MARK: - Init

    init() {
        let realm = try! Realm()
        scanObjects = realm.objects(ScanRealm.self)
        scans = Observable.array(from: scanObjects)
            .map { scanned in
                return scanned.map { $0.toScan() }
            }
    }

    // MARK: - Sections

    var sections: Driver<[SectionModel]> {
        return Observable.combineLatest(scans, selectedSegmentIndex)
            .map { unfilteredScans, selectedSegmentIndex -> [Scan] in
                return unfilteredScans.filter { scan in
                    guard let medianRssi = scan.medianRssi else { return false }
                    return selectedSegmentIndex == 0 ? true : (medianRssi >= RemoteValues.criticalExpositionRssi)
                }
            }
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

extension DataListVM {

    private func section(from scans: [Scan]) -> [SectionModel] {
        let header = DataListVM.Section.Item.header
        let scanningInfo = DataListVM.Section.Item.scanningInfo
        let aboutData = DataListVM.Section.Item.aboutData
        let items: [DataListVM.Section.Item] = scans.map { .data($0) }
        return [
            SectionModel(model: .list, items: [scanningInfo, aboutData, header] + items)
        ]
    }

}

// MARK: - Sections

extension DataListVM {

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
            case header
            case data(Scan)
            case scanningInfo
            case aboutData

            var identity: String {
                switch self {
                case .header:
                    return "header"
                case .data(let scan):
                    return scan.id
                case .scanningInfo:
                    return "scanningInfo"
                case .aboutData:
                    return "aboutData"
                }
            }

            var date: Date? {
                switch self {
                case .header, .scanningInfo, .aboutData:
                    return nil
                case .data(let scan):
                    return scan.date
                }
            }

            static func == (lhs: Item, rhs: Item) -> Bool {
                return lhs.identity == rhs.identity && lhs.date == rhs.date
            }
        }
    }

}
