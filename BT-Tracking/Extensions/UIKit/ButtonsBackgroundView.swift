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

    var isGradientHidden: Bool = false {
        didSet {
            gradientView?.isHidden = isGradientHidden
        }
    }

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
        
        let gradientView = GradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        insertSubview(gradientView, at: 0)
        self.gradientView = gradientView

        gradientView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        gradientView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        gradientView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let bottomView = UIView()
        bottomView.backgroundColor = gradientView.backgroundColor
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(bottomView, at: 1)

        bottomView.topAnchor.constraint(equalTo: gradientView.bottomAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    func connect(with scrollView: UIScrollView) {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height + Self.TopOffset, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        scrollView.rx.contentOffset.asDriver().drive(onNext: { [weak self] offset in
            guard let self = self else { return }
            let hideGradient = offset.y - scrollView.adjustedContentInset.top + scrollView.bounds.height + 16 >= scrollView.contentSize.height
            self.isGradientHidden = hideGradient
        }).disposed(by: disposeBag)
    }

}
