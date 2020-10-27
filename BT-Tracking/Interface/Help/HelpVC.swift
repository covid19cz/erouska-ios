//
//  HelpVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

final class HelpVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private weak var helpSearch: HelpSearchVC!

    private let viewModel = HelpVM()
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<HelpVM.Section>!

    // MARK: -

    override func awakeFromNib() {
        super.awakeFromNib()

        navigationController?.tabBarItem.title = L10n.helpTabTitle
        navigationController?.tabBarItem.image = Asset.help.image
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.helpTitle
        navigationItem.rightBarButtonItem?.title = L10n.about
        navigationController?.tabBarItem.title = L10n.helpTabTitle

        view.backgroundColor = Asset.helpBackground.color
        tableView.backgroundColor = view.backgroundColor
        tableView.tableFooterView = UIView()

        setupDataSource()

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(HelpArticle.self)
            .subscribe(onNext: { [weak self] value in
                if let indexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }
                self?.perform(segue: StoryboardSegue.Help.article, sender: value)
            })
            .disposed(by: disposeBag)

        helpSearch = StoryboardScene.Help.helpSearchVC.instantiate()
        helpSearch.didSelectArticle = { [weak self] article in
            self?.perform(segue: StoryboardSegue.Help.article, sender: article)
        }
        viewModel.sections.asObservable().bind { [weak self] sections in
            self?.helpSearch.articles = sections
        }.disposed(by: disposeBag)

        let searchController = UISearchController(searchResultsController: helpSearch)
        searchController.searchResultsUpdater = helpSearch

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch StoryboardSegue.Help(segue) {
        case .article:
            guard let article = sender as? HelpArticle else { return }
            let controller = segue.destination as? HelpArticleVC
            controller?.title = article.title
            controller?.markdownLines = article.lines
        default:
            break
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.update()
    }

}

private extension HelpVC {

    func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<HelpVM.Section>(configureCell: { [weak self] _, _, _, item in
            self?.configureCell(with: item) ?? UITableViewCell()
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionModels[index].model
        }
    }

    func configureCell(with item: HelpArticle) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell") ?? UITableViewCell()
        cell.textLabel?.text = item.title
        return cell
    }

}
