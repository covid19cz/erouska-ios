//
//  DataListVM.swift
// eRouska
//
//  Created by Lukáš Foldýna on 23/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import RxRealm
import RealmSwift
import UIKit

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

    private let bag = DisposeBag()

    // MARK: - Init

    init() {

    }

    // MARK: - Sections

    var sections: Driver<[SectionModel]> {
        return Driver.just(section())
    }

}

// MARK: - Sections helpers

extension DataListVM {

    private func section() -> [SectionModel] {
        let header = DataListVM.Section.Item.header
        let scanningInfo = DataListVM.Section.Item.scanningInfo
        let aboutData = DataListVM.Section.Item.aboutData
        return [
            SectionModel(model: .list, items: [scanningInfo, aboutData, header])
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
            case scanningInfo
            case aboutData

            var identity: String {
                switch self {
                case .header:
                    return "header"
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
                }
            }

            static func == (lhs: Item, rhs: Item) -> Bool {
                return lhs.identity == rhs.identity && lhs.date == rhs.date
            }
        }
    }

}
