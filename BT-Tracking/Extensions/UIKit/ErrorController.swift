//
//  ErrorController.swift
//  BT-Tracking
//
//  Created by Michal Šrůtek on 16/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ErrorController: UIViewController {

    // MARK: - Constants
    private struct Constants {
        static let defaultCloseTitle = "Zavřít"
    }

    // MARK: - Private Properties
    private let errorImage = UIImageView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let primaryActionButton = RoundedButtonFilled()
    private let secondaryActionButton = RoundedButtonClear()

    private var primaryHandler: (() -> Void)?
    private var secondaryHandler: (() -> Void)?

    // MARK: - Init

    init(
        pageTitle: String? = nil,
        title: String = "Chyba",
        message: String,
        primaryAction: (title: String, handler: (() -> Void)?)? = nil,
        secondaryAction: (title: String, handler: (() -> Void)?)? = nil
    ) {
        super.init(nibName: nil, bundle: nil)

        setupViews()
        layoutViews()

        setupTitle(pageTitle: pageTitle, title: title)
        setupContent(title: title, message: message)

        setupPrimaryButton(action: primaryAction)
        setupSecondaryButton(action: secondaryAction)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setups

    private func setupViews() {
        edgesForExtendedLayout = []

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        errorImage.image = UIImage(named: "Error")

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = UIColor(red: 223/255, green: 96/255, blue: 97/255, alpha: 1)

        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .preferredFont(forTextStyle: .callout)

        if #available(iOS 13.0, *) {
            subtitleLabel.textColor = .label
        } else {
            subtitleLabel.textColor = .black
        }
    }

    private func layoutViews() {
        [titleLabel, subtitleLabel, primaryActionButton, secondaryActionButton].forEach {
            stackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [errorImage, stackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            errorImage.widthAnchor.constraint(equalToConstant: 130),
            errorImage.heightAnchor.constraint(equalToConstant: 130),
            errorImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stackView.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            primaryActionButton.heightAnchor.constraint(equalToConstant: 38),
            secondaryActionButton.heightAnchor.constraint(equalToConstant: 38)
        ])
    }

    private func setupTitle(pageTitle: String?, title: String) {
        self.title = pageTitle ?? title
    }

    private func setupContent(title: String, message: String) {
        titleLabel.text = title
        subtitleLabel.text = message
    }

    private func setupPrimaryButton(action: (title: String, handler: (() -> Void)?)?) {
        primaryActionButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)

        if let action = action {
            primaryActionButton.setTitle(action.title, for: .normal)
            primaryHandler = action.handler
        } else {
            primaryActionButton.setTitle(Constants.defaultCloseTitle, for: .normal)
        }
    }

    private func setupSecondaryButton(action: (title: String, handler: (() -> Void)?)?) {
        secondaryActionButton.addTarget(self, action: #selector(didTapSecondaryButton), for: .touchUpInside)

        if let action = action {
            secondaryActionButton.setTitle(action.title, for: .normal)
            secondaryHandler = action.handler
        } else {
            secondaryActionButton.isHidden = true
        }
    }


    // MARK: - Actions

    @objc private func didTapPrimaryButton() {
        primaryHandler?()
        dismiss(animated: true)
    }

    @objc private func didTapSecondaryButton() {
        secondaryHandler?()
        dismiss(animated: true)
    }
}
