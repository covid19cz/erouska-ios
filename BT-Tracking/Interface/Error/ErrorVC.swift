//
//  ErrorVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 18/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ErrorVC: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var actionButton: Button!

    var viewModel: ErrorVM?

    static func instantiateViewController(with viewModel: ErrorVM) -> UIViewController? {
        let navVC = StoryboardScene.Error.initialScene.instantiate()
        guard let errorVC = navVC.topViewController as? ErrorVC else { return nil }
        errorVC.viewModel = viewModel
        return navVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.errorTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.help, style: .plain, target: self, action: #selector(showHelp))

        headlineLabel.text = viewModel?.headline
        textLabel.text = viewModel?.text
        actionButton.setTitle(viewModel?.actionTitle ?? "", for: .normal)
        buttonsView.connect(with: scrollView)

        isModalInPresentation = true
    }

    @IBAction private func action() {
        switch viewModel?.action {
        case .close:
            close()
        case .closeAndCustom(let customAction):
            closeWith(completion: customAction)
        case .none:
            break
        }
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func showHelp() {
        perform(segue: StoryboardSegue.Error.help)
    }

    private func closeWith(completion: @escaping CallbackVoid) {
        dismiss(animated: true, completion: completion)
    }
}
