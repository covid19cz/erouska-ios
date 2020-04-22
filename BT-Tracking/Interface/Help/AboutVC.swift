//
//  AboutVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 21/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AboutVC: UIViewController {

    private var dataSource: RxTableViewSectionedAnimatedDataSource<AboutVM.SectionModel>!
    private let viewModel = AboutVM()
    private let bag = DisposeBag()

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: indexPath, animated: animated)
    }

}

extension AboutVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        let person = viewModel.teams[indexPath.section - 1].people[indexPath.row]
        guard let rawURL = person.linkedin, let URL = URL(string: rawURL) else { return }
        openURL(URL: URL)
    }

}

private extension AboutVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
    }

    func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension

        dataSource = RxTableViewSectionedAnimatedDataSource<AboutVM.SectionModel>(
            configureCell: { datasource, tableView, indexPath, row in
                switch row {
                case .info:
                    return tableView.dequeueReusableCell(withIdentifier: AboutInfoCell.identifier, for: indexPath)
                case .person(let person):
                    let cell = tableView.dequeueReusableCell(withIdentifier: AboutPersonCell.identifier, for: indexPath) as? AboutPersonCell
                    cell?.configure(name: person.fullname, avatar: person.photoUrl)
                    return cell ?? UITableViewCell()
                }
            },
            titleForHeaderInSection: { [weak self] section, index in
                guard index > 0 else { return nil }
                return self?.viewModel.teams[index - 1].name
            }
        )

        viewModel.sections.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        tableView.rx.setDelegate(self)
            .disposed(by: bag)

        tableView.rx.modelSelected(AboutVM.Section.Item.self)
            .subscribe(onNext: { [weak self] item in
                switch item {
                case .person(let person):
                    guard let rawUrl = person.linkedin, let url = URL(string: rawUrl) else { return }
                    self?.openURL(URL: url)
                default:
                    break
                }
            })
            .disposed(by: bag)

        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .fade)
    }

}
