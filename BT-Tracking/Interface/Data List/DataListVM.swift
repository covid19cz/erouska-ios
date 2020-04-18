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

    // MARK: - Localization

    let tabTitle = "data_list_title"
    var tabIcon: UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "doc.plaintext")
        } else {
            return UIImage(named: "doc.plaintext")?.resize(toWidth: 20)
        }
    }

    let title = "data_list_title"
    let infoButton = "data_list_info_button"
    let deleteButton = "data_list_delete_button"
    let sendButton = "data_list_send_button"

    let sendDataQuestionTitle = "data_list_send_question_title"
    let sendDataQuestionMessage = "data_list_send_question_message"
    let sendDataQuestionYes = "data_list_send_question_yes"
    let sendDataQuestionNo = "data_list_send_question_no"

    let sendDataErrorWait = "data_list_send_error_wait"
    let sendDataErrorFailedTitle = "data_list_send_error_failed_title"
    let sendDataErrorFailedMessage = "data_list_send_error_failed_message"
    let sendDataErrorFile = "data_list_send_error_file_title"
    let sendDataErrorOnlyAfter = "data_list_send_error_only_after_message"

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
