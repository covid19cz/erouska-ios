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

final class HelpVC: BaseController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasHelpService & HasDiagnosis

    var dependencies: Dependencies!

    // MARK: -

    @IBOutlet private weak var tableView: UITableView!
    private weak var helpSearch: HelpSearchVC!

    private var viewModel: HelpVM!
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
        viewModel = HelpVM(helpService: dependencies.help)

        super.viewDidLoad()

        title = L10n.helpTitle
        navigationItem.rightBarButtonItem?.title = L10n.about
        navigationController?.tabBarItem.title = L10n.helpTabTitle

        view.backgroundColor = Asset.helpBackground.color
        tableView.backgroundColor = view.backgroundColor

        let view = UIView()
        view.frame.size.height = 26
        view.isUserInteractionEnabled = true

        let button = UIButton(type: .system)
        button.autoresizingMask = .flexibleWidth
        button.frame.size.height = 26
        button.setTitle(L10n.helpSupport)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(writeToSupport), for: .touchUpInside)
        view.addSubview(button)
        tableView.tableFooterView = view

        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: 15, left: 0, bottom: 20, right: 0)

        setupDataSource()

        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(HelpSection.self)
            .subscribe(onNext: { [weak self] section in
                let indexPath = self?.tableView.indexPathForSelectedRow
                if let indexPath = indexPath {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }
                self?.openSection(section)
            })
            .disposed(by: disposeBag)

        helpSearch = StoryboardScene.Help.helpSearchVC.instantiate()
        helpSearch.didSelectQuestion = { [weak self] question in
            self?.openQuestion(question)
        }
        viewModel.sections.asObservable().bind { [weak self] sections in
            self?.helpSearch.questions = sections.first?.items.map { HelpSectionVC.Section(model: $0, items: $0.questions) } ?? []
        }.disposed(by: disposeBag)

        let searchController = UISearchController(searchResultsController: helpSearch)
        searchController.searchResultsUpdater = helpSearch
        searchController.hidesNavigationBarDuringPresentation = true

        definesPresentationContext = true

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch StoryboardSegue.Help(segue) {
        case .section:
            guard let section = sender as? HelpSection else { return }
            let controller = segue.destination as? HelpSectionVC
            controller?.title = section.title
            controller?.section = section
        case .question:
            guard let question = sender as? HelpQuestion else { return }
            let controller = segue.destination as? HelpQuestionVC
            controller?.title = question.question
            controller?.markdownLines = question.lines
        default:
            break
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.update()
    }

    // MARK: - Action

    private func openSection(_ section: HelpSection) {
        if section.title == L10n.howitworksTitle {
            perform(segue: StoryboardSegue.Help.howItWorks)
        } else if section.title == L10n.about {
            perform(segue: StoryboardSegue.Help.about)
        } else {
            perform(segue: StoryboardSegue.Help.section, sender: section)
        }
    }

    private func openQuestion(_ question: HelpQuestion) {
        perform(segue: StoryboardSegue.Help.question, sender: question)
    }

    @IBAction private func writeToSupport() {
        guard let url = URL(string: "mailto:info@erouska.cz") else { return }
        openLink(url)
    }

    private func openLink(_ link: URL) {
        if link.absoluteString.hasSuffix("info@erouska.cz"), dependencies.diagnosis.canSendMail {
            dependencies.diagnosis.present(fromController: self, screenName: .help, kind: .error(nil))
        } else {
            openURL(URL: link)
        }
    }

}

private extension HelpVC {

    func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<HelpVM.Section>(configureCell: { [weak self] _, _, _, item in
            self?.configureCell(with: item) ?? UITableViewCell()
        })
    }

    func configureCell(with item: HelpSection) -> UITableViewCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as? HelpSectionCell else { return nil }
        cell.config(with: item.title, subtitle: item.subtitle, icon: item.icon, image: item.image)
        return cell
    }

}
