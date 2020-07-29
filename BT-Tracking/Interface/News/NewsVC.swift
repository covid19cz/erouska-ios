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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pagesStackView: UIStackView!
    @IBOutlet weak var pageSizeReferenceView: UIView!
    @IBOutlet weak var actionButton: RoundedButtonFilled!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle(viewModel.title)
        actionButton.localizedTitle(viewModel.closeButton)

        let nib = UINib(nibName: "NewsPageView", bundle: nil)
        pagesStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        viewModel.newsPages.forEach { pageModel in
            let page = nib.instantiate(withOwner: nil, options: nil).first as! NewsPageView
            page.viewModel = pageModel
            page.translatesAutoresizingMaskIntoConstraints = true
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

    @IBAction func actionButtonPressed(_ sender: Any) {
        if pageControl.currentPage == viewModel.newsPages.count - 1 {
            dismiss(animated: true, completion: nil)
        } else {
            pageControl.currentPage += 1
            scrollToPage(at: pageControl.currentPage)
        }
    }

    @IBAction func pageControlValueChanged(_ sender: Any) {
        scrollToPage(at: pageControl.currentPage)
    }

    private func updateView(for page: Int) {
        actionButton.localizedTitle(page == viewModel.newsPages.count - 1 ? viewModel.closeButton : viewModel.continueButton)
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
