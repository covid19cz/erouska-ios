//
//  IntrinsicTableView.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 24/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

open class IntrinsicTableView: UITableView {

    override open var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }

    public var minimumHeight: CGFloat? {
        didSet { invalidateIntrinsicContentSize() }
    }

    override open var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: max(contentSize.height, minimumHeight ?? 0))
    }
}
