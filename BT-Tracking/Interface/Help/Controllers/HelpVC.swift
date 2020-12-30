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

        navigationController?.tabBarItem.tag = MainTab.help.rawValue
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
        tableView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)

        setupDataSource()

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(HelpArticle.self)
            .subscribe(onNext: { [weak self] article in
                let indexPath = self?.tableView.indexPathForSelectedRow
                if let indexPath = indexPath {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }
                self?.openArticle(article)
            })
            .disposed(by: disposeBag)

        helpSearch = StoryboardScene.Help.helpSearchVC.instantiate()
        helpSearch.didSelectArticle = { [weak self] article in
            self?.openArticle(article)
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

    // MARK: - Action

    private func openArticle(_ article: HelpArticle) {
        if article.title == L10n.howitworksTitle {
            perform(segue: StoryboardSegue.Help.howItWorks)
        } else {
            perform(segue: StoryboardSegue.Help.article, sender: article)
        }
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
