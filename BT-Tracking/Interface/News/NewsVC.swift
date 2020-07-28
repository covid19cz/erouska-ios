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
    @IBOutlet weak var closeButton: RoundedButtonFilled!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle(viewModel.title)
        closeButton.localizedTitle(viewModel.closeButton)

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
        dismiss(animated: true, completion: nil)
    }

    @IBAction func pageControlValueChanged(_ sender: Any) {
        var rectToScroll = pageSizeReferenceView.bounds
        rectToScroll.origin.x = CGFloat(pageControl.currentPage) * pageSizeReferenceView.bounds.width
        scrollView.scrollRectToVisible(rectToScroll, animated: true)
        updateView(for: pageControl.currentPage)
    }

    private func updateView(for page: Int) {
        pageControl.isHidden = page == viewModel.newsPages.count - 1
        closeButton.isHidden = page != viewModel.newsPages.count - 1
    }
}

extension NewsVC: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = max(0, Int(scrollView.contentOffset.x / pageSizeReferenceView.bounds.width))
        pageControl.currentPage = currentPage
        updateView(for: currentPage)
    }
}
