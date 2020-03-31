//
//  UnregisterUserVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 30/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth

final class UnregisterUserVC: UIViewController {

    @IBOutlet private weak var activityView: UIView!
    @IBOutlet private weak var textLabel: UILabel!

    private let scannerStore: ScannerStore = AppDelegate.shared.scannerStore

    override func viewDidLoad() {
        super.viewDidLoad()

        textLabel.text = textLabel.text?.replacingOccurrences(of: "%@", with: Auth.auth().currentUser?.phoneNumber ?? "")
    }

    // MARK: - Actions

    @IBAction private func unregisterAction() {
        activityView.isHidden = false
        AppDelegate.shared.functions.httpsCallable("deleteUser").call() { [weak self] result, error in
            guard let self = self else { return }
            self.activityView.isHidden = true

            if let error = error as NSError? {
                Log.log("deleteUser request failed with error: \(error.localizedDescription)")
                self.show(error: error, title: "Chyba při zrušení registrace")
                self.scannerStore.deleteAllData()
                return
            }

            Log.log("deleteUser request success finished")
            self.scannerStore.deleteAllData()
            AppSettings.deleteAllData()

            self.performSegue(withIdentifier: "finish", sender: nil)
        }
    }
}
