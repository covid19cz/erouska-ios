//
//  ErrorVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 18/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class ErrorVC: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!

    var viewModel: ErrorVM?

    static func instantiateViewController(with viewModel: ErrorVM) -> UIViewController? {
        guard
            let navVC = UIStoryboard(name: "Error", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let errorVC = navVC.topViewController as? ErrorVC
        else { return nil }

        errorVC.viewModel = viewModel
        return navVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable("error_title")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Localizable("help"), style: .plain, target: self, action: #selector(showHelp))

        headlineLabel.text = viewModel?.headline
        textLabel.text = viewModel?.text
        actionButton.setTitle(viewModel?.actionTitle ?? "", for: .normal)
    }

    @IBAction func action() {
        switch viewModel?.action {
        case .close:
            close()
        case .closeAndCustom(let customAction):
            closeWith(completion: customAction)
        case .none:
            break
        }
    }

    @objc func close() {
        dismiss(animated: true)
    }

    @objc func showHelp() {
        performSegue(withIdentifier: "Help", sender: nil)
    }

    func closeWith(completion: @escaping () -> Void) {
        dismiss(animated: true, completion: completion)
    }
}
