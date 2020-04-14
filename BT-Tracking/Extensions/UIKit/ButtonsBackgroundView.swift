//
//  ButtonsBackgroundView.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 14/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift

class ButtonsBackgroundView: UIView {

    static var TopOffset: CGFloat = -44

    static var BottomMargin: CGFloat = 16

    var isGradientHidden: Bool = false {
        didSet {
            gradientView?.isHidden = isGradientHidden
        }
    }

    var defaultContentInset: UIEdgeInsets = .zero

    private weak var gradientView: GradientView?
    private let disposeBag = DisposeBag()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = false
        
        let gradientView = GradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        if subviews.isEmpty {
            addSubview(gradientView)
        } else {
            insertSubview(gradientView, at: 0)
        }
        self.gradientView = gradientView

        gradientView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        gradientView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        gradientView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let bottomView = UIView()
        bottomView.backgroundColor = gradientView.backgroundColor
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(bottomView, belowSubview: gradientView)

        bottomView.topAnchor.constraint(equalTo: gradientView.bottomAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Self.BottomMargin).isActive = true
        bottomView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    func resetInsets(in scrollView: UIScrollView) {
        scrollView.contentInset = defaultContentInset
        scrollView.scrollIndicatorInsets = defaultContentInset
    }

    func connect(with scrollView: UIScrollView) {
        defaultContentInset.bottom = frame.height + Self.TopOffset
        scrollView.contentInset = defaultContentInset
        scrollView.scrollIndicatorInsets = defaultContentInset

        scrollView.rx.contentOffset.asDriver().drive(onNext: { [weak self] offset in
            guard let self = self else { return }
            let bottomContentOffsetDiff = scrollView.contentInset.bottom - self.defaultContentInset.bottom
            let hideGradient = offset.y - scrollView.adjustedContentInset.top + scrollView.bounds.height + Self.BottomMargin - bottomContentOffsetDiff >= scrollView.contentSize.height
            self.isGradientHidden = hideGradient
        }).disposed(by: disposeBag)
    }

}
