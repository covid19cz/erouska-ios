//
//  KeyboardHandler.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 14/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxKeyboard

struct KeyboardHandler {

    let view: UIView
    let scrollView: UIScrollView
    let buttonsView: ButtonsBackgroundView
    let buttonsBottomConstraint: NSLayoutConstraint
    let disposeBag = DisposeBag()

    init(in view: UIView, scrollView: UIScrollView, buttonsView: ButtonsBackgroundView, buttonsBottomConstraint: NSLayoutConstraint) {
        self.view = view
        self.scrollView = scrollView
        self.buttonsView = buttonsView
        self.buttonsBottomConstraint = buttonsBottomConstraint
    }

    func setup() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [self] keyboardVisibleHeight in
            self.handle(keyboardVisibleHeight: keyboardVisibleHeight)
        }).disposed(by: disposeBag)
    }

    func handle(keyboardVisibleHeight: CGFloat) {
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()

            guard keyboardVisibleHeight > 0 else {
                self.buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin
                self.buttonsView.resetInsets(in: self.scrollView)
                return
            }
            let adjustedHeight = keyboardVisibleHeight - self.view.safeAreaInsets.bottom
            self.buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin + adjustedHeight
            self.scrollView.contentInset.bottom = adjustedHeight + self.buttonsView.defaultContentInset.bottom
            self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset

            DispatchQueue.main.async {
                let height = (self.scrollView.frame.height - adjustedHeight)
                let contentSize = self.scrollView.contentSize
                guard contentSize.height - height > -60 else { return }
                self.scrollView.scrollRectToVisible(CGRect(x: 0, y: (contentSize.height - height), width: contentSize.width, height: height), animated: true)
            }
        }, completion: nil)
    }

}
