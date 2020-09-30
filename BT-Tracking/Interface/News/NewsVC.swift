//
//  NewsVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 28/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class NewsVC: UIViewController {

    private var viewModel = NewsVM()

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pagesStackView: UIStackView!
    @IBOutlet private weak var pageSizeReferenceView: UIView!
    @IBOutlet private weak var actionButton: RoundedButtonFilled!
    @IBOutlet private weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle(.news_title)
        actionButton.localizedTitle(.news_button_close)

        let nib = UINib(nibName: "NewsPageView", bundle: nil)
        pagesStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        viewModel.newsPages.forEach { pageModel in
            guard let page = nib.instantiate(withOwner: nil, options: nil).first as? NewsPageView else { return }
            page.viewModel = pageModel
            page.translatesAutoresizingMaskIntoConstraints = true
            page.bodyTextDelegate = self
            pagesStackView.addArrangedSubview(page)
        }
        pageControl.numberOfPages = viewModel.newsPages.count
        updateView(for: 0)
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        pagesStackView.arrangedSubviews.forEach {
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalTo: pageSizeReferenceView.widthAnchor),
                $0.heightAnchor.constraint(equalTo: pageSizeReferenceView.heightAnchor)
            ])
        }
    }

    @IBAction private func actionButtonPressed(_ sender: Any) {
        if pageControl.currentPage == viewModel.newsPages.count - 1 {
            dismiss(animated: true, completion: nil)
        } else {
            pageControl.currentPage += 1
            scrollToPage(at: pageControl.currentPage)
        }
    }

    @IBAction private func pageControlValueChanged(_ sender: Any) {
        scrollToPage(at: pageControl.currentPage)
    }

    private func updateView(for page: Int) {
        actionButton.localizedTitle(page == viewModel.newsPages.count - 1 ? .news_button_close : .news_button_continue)
    }

    private func scrollToPage(at index: Int) {
        var rectToScroll = pageSizeReferenceView.bounds
        rectToScroll.origin.x = CGFloat(pageControl.currentPage) * pageSizeReferenceView.bounds.width
        scrollView.scrollRectToVisible(rectToScroll, animated: true)
        updateView(for: index)
    }
}

extension NewsVC: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = max(0, Int(scrollView.contentOffset.x / pageSizeReferenceView.bounds.width))
        pageControl.currentPage = currentPage
        updateView(for: currentPage)
    }
}

extension NewsVC: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        openURL(URL: URL)
        return false
    }
}
