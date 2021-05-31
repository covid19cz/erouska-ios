//
//  ActiveAppSectionView.swift
//  eRouska
//
//  Created by Naim Ashhab on 24/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ActiveAppSectionView: UIView {
    let efgs: Bool
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let disclosureIndicator = UIImageView()
    let bodyLabel = UILabel()
    let actionButton = DashboardButton()
    let buttonView = UIView()

    private lazy var titleStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel, disclosureIndicator])
    private lazy var mainStack = UIStackView(arrangedSubviews: [titleStack, bodyLabel, buttonView])

    var isSelectable = false {
        didSet {
            buttonView.isHidden = isSelectable
        }
    }
    var isTappable = true {
        didSet {
            disclosureIndicator.isHidden = !isTappable
            tapGestureRecognizer.isEnabled = isTappable
        }
    }
    var isPositive = false {
        didSet {
            titleLabel.textColor = isPositive ? Asset.alertRed.color : .textLabel
        }
    }
    var action: CallbackVoid?

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonAction))

    init(efgs: Bool) {
        self.efgs = efgs
        super.init(frame: .zero)

        setup()
    }

    override init(frame: CGRect) {
        self.efgs = false
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        bodyLabel.isHidden = bodyLabel.text?.isEmpty ?? true
    }

    private func setup() {
        backgroundColor = .secondaryGroupedBackground
        layer.cornerRadius = 12.0
        if #available(iOS 13.0, *) {
            layer.shadowColor = UIColor.textLabel.resolvedColor(with: traitCollection).withAlphaComponent(0.2).cgColor
        } else {
            layer.shadowColor = UIColor.textLabel.withAlphaComponent(0.2).cgColor
        }
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 1

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        isSelectable = false

        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline).withSize(16)
        titleLabel.allowsDefaultTighteningForTruncation = true
        titleLabel.numberOfLines = 0

        bodyLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        bodyLabel.allowsDefaultTighteningForTruncation = true
        bodyLabel.numberOfLines = 0

        disclosureIndicator.image = Asset.disclosureIndicator.image

        titleStack.axis = .horizontal
        titleStack.spacing = 16
        titleStack.alignment = .center

        buttonView.addSubview(actionButton)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        mainStack.setCustomSpacing(10, after: titleStack)
        mainStack.setCustomSpacing(16, after: bodyLabel)

        if efgs {
            let efgsStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
            efgsStack.axis = .vertical
            efgsStack.spacing = 5
            titleStack.insertArrangedSubview(efgsStack, at: 1)
        }

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 42),

            actionButton.heightAnchor.constraint(equalToConstant: 32),
            actionButton.topAnchor.constraint(equalTo: buttonView.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
            actionButton.leftAnchor.constraint(equalTo: buttonView.leftAnchor),

            disclosureIndicator.heightAnchor.constraint(equalTo: disclosureIndicator.widthAnchor),
            disclosureIndicator.widthAnchor.constraint(equalToConstant: 24)
        ])

        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func buttonAction() {
        action?()
    }
}
