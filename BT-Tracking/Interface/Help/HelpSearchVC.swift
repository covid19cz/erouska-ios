//
//  HelpSearchVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 22/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

private class HelpSearchItem: NSObject {
    let article: HelpArticle
    @objc dynamic let type: String
    @objc dynamic let line: String

    init(article: HelpArticle, type: String, line: String) {
        self.article = article
        self.type = type
        self.line = line
    }
}

final class HelpSearchVC: UITableViewController {

    var articles: [HelpVM.Section] = [] {
        didSet {
            searchItems.removeAll()
            for section in articles {
                for article in section.items {
                    searchItems.append(.init(article: article, type: "title", line: article.title))
                    searchItems.append(contentsOf: article.lines.map { .init(article: article, type: "line", line: $0.line) })
                }
            }
        }
    }

    typealias ArticleCallback = (_ article: HelpArticle) -> Void
    var didSelectArticle: ArticleCallback?

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
            guard let article = sender as? HelpArticle else { return }
            let controller = segue.destination as? HelpArticleVC
            controller?.title = article.title
            controller?.markdownLines = article.lines
        default:
            break
        }
    }

    // MARK: - UITalbeViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") ?? UITableViewCell()
        let result = results[indexPath.row]
        cell.textLabel?.attributedText = highlightedString(string: result.article.title)
        if result.type != "title" {
            cell.detailTextLabel?.attributedText = highlightedString(string: result.line, startsFrom: 30)
        } else {
            cell.detailTextLabel?.attributedText = nil
        }
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        didSelectArticle?(results[indexPath.row].article)
    }

}

extension HelpSearchVC: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchBar: searchController.searchBar)
    }

}

private extension HelpSearchVC {

    func filterContentForSearchText(searchBar: UISearchBar?) {
        searchText = searchBar?.text ?? ""

        guard !searchText.isEmpty, searchText.count > 1 else {
            results = []
            return
        }
        let predicate = NSPredicate(format: "(line CONTAINS[cd] %@)", searchText)

        DispatchQueue.global(qos: .background).async { [weak self] in
            var results = self?.searchItems.filter({
                predicate.evaluate(with: $0)
            })
            results = results?.filter { item in
                results?.first(where: { item.article.id == $0.article.id }) == item
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
