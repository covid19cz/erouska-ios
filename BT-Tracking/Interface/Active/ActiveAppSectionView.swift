//
//  ActiveAppSectionView.swift
//  eRouska
//
//  Created by Naim Ashhab on 24/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ActiveAppSectionView: UIView {
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let disclosureIndicator = UIImageView()
    let bodyLabel = UILabel()
    let actionButton = Button(type: .system)

    private lazy var titleStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel, disclosureIndicator])
    private lazy var mainStack = UIStackView(arrangedSubviews: [titleStack, bodyLabel, actionButton])

    var isSelectable = false {
        didSet {
            disclosureIndicator.isHidden = !isSelectable
            actionButton.isHidden = isSelectable
            tapGestureRecognizer.isEnabled = isSelectable
        }
    }
    var action: () -> Void = {}

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()

        bodyLabel.isHidden = bodyLabel.text?.isEmpty ?? true
    }

    private func setup() {
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12.0
        layer.shadowColor = UIColor.label.resolvedColor(with: traitCollection).withAlphaComponent(0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 1

        addSubview(mainStack)
        isSelectable = false

        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2

        bodyLabel.font = UIFont.preferredFont(forTextStyle: .body)
        bodyLabel.numberOfLines = 0

        disclosureIndicator.image = Asset.disclosureIndicator.image

        titleStack.axis = .horizontal
        titleStack.spacing = 16
        titleStack.alignment = .center

        actionButton.style = .filled
        actionButton.layer.cornerRadius = 6
        actionButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        mainStack.setCustomSpacing(10, after: titleStack)
        mainStack.setCustomSpacing(16, after: bodyLabel)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),

            actionButton.heightAnchor.constraint(equalToConstant: 40),

            disclosureIndicator.heightAnchor.constraint(equalTo: disclosureIndicator.widthAnchor),
            disclosureIndicator.widthAnchor.constraint(equalToConstant: 24)
        ])

        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .recognized {
            action()
        }
    }

    @objc private func buttonPressed() {
        action()
    }
}
