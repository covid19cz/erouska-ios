//
//  HelpVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import SwiftyMarkdown
import RxSwift
import RxDataSources

final class HelpVC: MarkdownController {

    @IBOutlet private weak var tableView: UITableView!

    // MARK: -

    private let viewModel = HelpVM()

    private let lineProcessor = SwiftyLineProcessor(
        rules: SwiftyMarkdown.lineRules,
        defaultRule: MarkdownLineStyle.body,
        frontMatterRules: SwiftyMarkdown.frontMatterRules
    )

    struct ArticleModel {
        let title: String
        var lines: [SwiftyLine]
    }

    private var searchController = UISearchController()

    private typealias Section = SectionModel<String, ArticleModel>
    private var sections: Observable<[Section]> = Observable.just([])

    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<Section>!

    // MARK: -

    override func awakeFromNib() {
        super.awakeFromNib()

        navigationController?.tabBarItem.title = L10n.helpTabTitle
        navigationController?.tabBarItem.image = Asset.help.image

        markdownContent = viewModel.markdownContent

        var editedMD = markdownContent.replacingOccurrences(of: "\\n", with: "\u{0085}")
        editedMD = editedMD.replacingOccurrences(of: "(.pdf)", with: "")

        self.lineProcessor.processEmptyStrings = MarkdownLineStyle.body
        let foundAttributes: [SwiftyLine] = lineProcessor.process(editedMD)

        var sections: [Section] = []
        var section: Section = .init(model: "", items: [])
        var article: ArticleModel = .init(title: "", lines: [])

        for attribute in foundAttributes {
            guard let style = attribute.lineStyle as? MarkdownLineStyle else { continue }
            switch style {
            case .h1:
                if !section.items.isEmpty {
                    sections.append(section)
                }
                section = .init(model: attribute.line, items: [])
            case .h2:
                if !article.lines.isEmpty {
                    section.items.append(article)
                }
                article = ArticleModel(title: attribute.line, lines: [])
            default:
                article.lines.append(attribute)
            }
        }

        self.sections = Observable.just(sections)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.helpTitle
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem?.title = L10n.about

        view.backgroundColor = Asset.helpBackground.color
        tableView.backgroundColor = view.backgroundColor

        setupDataSource()

        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(ArticleModel.self)
            .subscribe(onNext: { [weak self] value in
                if let indexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }
                self?.perform(segue: StoryboardSegue.Help.article, sender: value)
            })
            .disposed(by: disposeBag)

        tableView.tableFooterView = UIView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch StoryboardSegue.Help(segue) {
        case .article:
            guard let article = sender as? ArticleModel else { return }
            let controller = segue.destination as? HelpArticleVC
            controller?.title = article.title
            controller?.markdownLines = article.lines
        default:
            break
        }
    }

    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<Section>(configureCell: { [weak self] _, _, _, item in
            self?.configureCell(item) ?? UITableViewCell()
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionModels[index].model
        }
    }

    private func configureCell(_ item: ArticleModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell") ?? UITableViewCell()
        cell.textLabel?.text = item.title
        return cell
    }

}
