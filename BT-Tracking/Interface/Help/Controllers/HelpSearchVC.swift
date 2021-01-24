//
//  HelpSearchVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 22/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

private class HelpSearchItem: NSObject {

    @objc enum Kind: Int {
        case title
        case line
    }

    let question: HelpQuestion
    @objc dynamic let kind: Kind
    @objc dynamic let line: String

    init(question: HelpQuestion, kind: Kind, line: String) {
        self.question = question
        self.kind = kind
        self.line = line
    }
}

final class HelpSearchVC: UITableViewController {

    var articles: [HelpVM.Section] = [] {
        didSet {
            searchItems.removeAll()
            for section in articles {
                for question in section.items {
                    searchItems.append(.init(question: question, kind: .title, line: question.question))
                    searchItems.append(contentsOf: question.lines.map { .init(question: question, kind: .line, line: $0.line) })
                }
            }
        }
    }

    typealias QuestionCallback = (_ quesntion: HelpQuestion) -> Void
    var didSelectQuestion: QuestionCallback?

    private var searchText: String = ""
    private var searchItems: [HelpSearchItem] = []

    private var results: [HelpSearchItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch StoryboardSegue.Help(segue) {
        case .article:
            guard let question = sender as? HelpQuestion else { return }
            let controller = segue.destination as? HelpQuestionVC
            controller?.title = question.question
            controller?.markdownLines = question.lines
        default:
            break
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") ?? UITableViewCell()
        let result = results[indexPath.row]
        cell.textLabel?.attributedText = highlightedString(string: result.question.question)
        if result.kind != .title {
            cell.detailTextLabel?.attributedText = highlightedString(string: result.line, startsFrom: 30)
        } else {
            cell.detailTextLabel?.attributedText = nil
        }
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        didSelectQuestion?(results[indexPath.row].question)
    }

}

extension HelpSearchVC: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        filterContent(with: searchController.searchBar.text ?? "")
    }

}

private extension HelpSearchVC {

    func filterContent(with searchText: String) {
        guard !searchText.isEmpty, searchText.count > 1 else {
            results = []
            return
        }
        self.searchText = searchText
        let predicate = NSPredicate(format: "(line CONTAINS[cd] %@)", searchText)

        DispatchQueue.global(qos: .background).async { [weak self] in
            var results = self?.searchItems.filter({
                predicate.evaluate(with: $0)
            })
            results = results?.filter { item in
                results?.first(where: { item.question == $0.question }) == item
            }

            DispatchQueue.main.async {
                self?.results = results ?? []
            }
        }
    }

    func highlightedString(string: String, startsFrom: Int = 0) -> NSAttributedString {
        let options: NSString.CompareOptions = [NSString.CompareOptions.caseInsensitive, .diacriticInsensitive]
        var range = (string as NSString).range(of: searchText, options: options)
        let attributedString: NSMutableAttributedString
        if startsFrom != 0, range.location != NSNotFound, range.location > startsFrom {
            let newString = "..." + (string as NSString).substring(from: range.location - startsFrom)
            range = (newString as NSString).range(of: searchText, options: options)
            attributedString = NSMutableAttributedString(string: newString, attributes: [.foregroundColor: UIColor.label])
        } else {
            attributedString = NSMutableAttributedString(string: string, attributes: [.foregroundColor: UIColor.label])
        }

        if range.location != NSNotFound {
            attributedString.setAttributes([.foregroundColor: UIColor.systemBlue], range: range)
        }
        return attributedString
    }

}
