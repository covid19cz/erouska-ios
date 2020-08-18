//
//  PrivacyVC.swift
//  eRouska
//
//  Created by Naim Ashhab on 23/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseFunctions

final class PrivacyVC: UIViewController {

    // MARK: -

    private let viewModel = PrivacyVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var continueButton: RoundedButtonFilled!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
        setupStrings()
    }

    // MARK: - Action

    @IBAction func continueAction(_ sender: Any) {
        activateApp()
    }

}

private extension PrivacyVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.help)

        headlineLabel.localizedText(viewModel.headline)
        bodyLabel.localizedText(viewModel.body)
        continueButton.localizedTitle(viewModel.continueButton)
    }

    func activateApp() {
        showProgress()

        let request: [String: Any] = [
            "platform": "ios",
            "platformVersion": Version.currentOSVersion.rawValue,
            "manufacturer": "apple",
            "model": UIDevice.current.modelName,
            "locale": Locale.current.languageCode ?? ""
        ]

        viewModel.functions.httpsCallable("RegisterEhrid").call(request) { [weak self] result, error in
            self?.hideProgress()
            if let eHRID = (result?.data as? [String: Any])?["ehrid"] as? String {
                KeychainService.eHRID = eHRID
                let storyboard = UIStoryboard(name: "Active", bundle: nil)
                AppDelegate.shared.window?.rootViewController = storyboard.instantiateInitialViewController()
            } else {
                let viewModel: ErrorVM
                if let error = error, (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    viewModel = ErrorVM(
                        headline: Localizable("error_activation_internet_headline"),
                        text: Localizable("error_activation_internet_text"),
                        actionTitle: Localizable("error_activation_internet_title_action"),
                        action: { self?.activateApp() }
                    )
                } else {
                    viewModel = ErrorVM.unknown
                }
                if let errorVC = ErrorVC.instantiateViewController(with: viewModel) {
                    self?.present(errorVC, animated: true)
                }
            }
        }
    }

}
