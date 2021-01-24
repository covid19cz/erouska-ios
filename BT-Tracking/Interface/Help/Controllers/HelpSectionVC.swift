//
//  HelpSectionVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class HelpSectionVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private weak var helpSearch: HelpSearchVC!

    var section: HelpSection? {
        didSet {
            if let value = section {
                viewModel.accept([SectionModel(model: value, items: value.questions)])
            } else {
                viewModel.accept([])
            }
        }
    }

    typealias Section = SectionModel<HelpSection, HelpQuestion>
    private let viewModel: BehaviorRelay<[Section]> = .init(value: [])
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<HelpSection, HelpQuestion>>!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        title = section?.title
        navigationItem.rightBarButtonItem?.title = L10n.about
        navigationController?.tabBarItem.title = L10n.helpTabTitle

        view.backgroundColor = Asset.helpBackground.color
        tableView.backgroundColor = view.backgroundColor
        tableView.tableFooterView = UIView()
        tableView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)

        setupDataSource()

        viewModel
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(HelpQuestion.self)
            .subscribe(onNext: { [weak self] question in
                let indexPath = self?.tableView.indexPathForSelectedRow
                if let indexPath = indexPath {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }
                self?.openQuestion(question)
            })
            .disposed(by: disposeBag)

        helpSearch = StoryboardScene.Help.helpSearchVC.instantiate()
        helpSearch.didSelectQuestion = { [weak self] question in
            self?.openQuestion(question)
        }
        viewModel.asObservable().bind { [weak self] sections in
            self?.helpSearch.questions = sections
        }.disposed(by: disposeBag)

        let searchController = UISearchController(searchResultsController: helpSearch)
        searchController.searchResultsUpdater = helpSearch

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch StoryboardSegue.Help(segue) {
        case .question:
            guard let question = sender as? HelpQuestion else { return }
            let controller = segue.destination as? HelpQuestionVC
            controller?.title = question.question
            controller?.markdownLines = question.lines
        default:
            break
        }
    }

    // MARK: - Action

    private func openQuestion(_ question: HelpQuestion) {
        perform(segue: StoryboardSegue.Help.question, sender: question)
    }

}

private extension HelpSectionVC {

    func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<HelpSectionVC.Section>(configureCell: { [weak self] _, _, _, item in
            self?.configureCell(with: item) ?? UITableViewCell()
        })
    }

    func configureCell(with item: HelpQuestion) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell") ?? UITableViewCell()
        cell.textLabel?.text = item.question
        return cell
    }

}
