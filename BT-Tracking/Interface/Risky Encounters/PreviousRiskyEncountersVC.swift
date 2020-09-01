//
//  PreviousRiskyEncountersVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 10/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxRealm

final class PreviousRiskyEncountersVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = PreviousRiskyEncountersVM()
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        viewModel.previousExposures.bind(to: tableView.rx.items) { [dateFormatter] tv, ip, element in
            let cell = tv.dequeueReusableCell(withIdentifier: "PreviousRiskyEncountersCell")!
            cell.textLabel?.text = dateFormatter.string(from: element.date)
            cell.selectionStyle = .none
            return cell
        }.disposed(by: disposeBag)

        tableView.tableFooterView = UIView()
    }
}
