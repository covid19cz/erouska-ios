//
//  UnregisterUserVC.swift
// eRouska
//
//  Created by Lukáš Foldýna on 30/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth

final class UnregisterUserVC: UIViewController {

    // MARK: -

    private let viewModel = UnregisterUserVM()

    // MARK: - Outlets

    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle(viewModel.title)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.help)

        bodyLabel.localizedText(viewModel.body, values: Auth.auth().currentUser?.phoneNumber?.phoneFormatted ?? "")
        actionButton.localizedTitle(viewModel.actionButton)
    }

    // MARK: - Actions

    @IBAction private func unregisterAction() {
        showProgress()
        
        AppDelegate.dependency.functions.httpsCallable("deleteUser").call() { [weak self] result, error in
            guard let self = self else { return }
            self.hideProgress()

            if let error = error as NSError?,
                error.code != AuthErrorCode.userNotFound.rawValue {
                Log.log("deleteUser request failed with error: \(error.localizedDescription)")
                self.show(error: error, title: self.viewModel.errorTitle)
                return
            }

            #if !PROD
            FileLogger.shared.purgeLogs()
            #endif
            Log.log("deleteUser request success finished")

            AppDelegate.dependency.exposureService.deactivate { _ in }

            AppSettings.deleteAllData()

            self.performSegue(withIdentifier: "finish", sender: nil)
        }
    }

}
