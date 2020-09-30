//
//  PrivacyVC.swift
//  eRouska
//
//  Created by Naim Ashhab on 23/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFunctions

final class PrivacyVC: UIViewController {

    // MARK: -

    private let viewModel = PrivacyVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyTextView: UITextView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var continueButton: RoundedButtonFilled!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)

        title = L10n.privacyTitle
        navigationItem.backBarButtonItem?.title = L10n.back
        navigationItem.rightBarButtonItem?.title = L10n.back

        headlineLabel.text = L10n.privacyHeadline
        continueButton.setTitle(L10n.privacyContinue)

        bodyTextView.textContainerInset = .zero
        bodyTextView.textContainer.lineFragmentPadding = 0

        bodyTextView.hyperLink(
            originalText: L10n.privacyBody,
            hyperLink: L10n.privacyBodyLink,
            urlString: viewModel.bodyLink
        )
    }

    // MARK: - Action

    @IBAction private func continueAction(_ sender: Any) {
        activateApp()
    }

}

private extension PrivacyVC {

    func activateApp() {
        showProgress()

        let request: [String: Any] = [
            "platform": "ios",
            "platformVersion": Version.currentOSVersion.rawValue,
            "manufacturer": "apple",
            "model": UIDevice.current.modelName,
            "locale": Locale.current.languageCode ?? "",
            "pushRegistrationToken": AppDelegate.dependency.deviceToken?.hexEncodedString() ?? "💩"
        ]

        viewModel.functions.httpsCallable("RegisterEhrid").call(request) { [weak self] result, error in
            self?.hideProgress()
            if let customToken = (result?.data as? [String: Any])?["customToken"] as? String {
                Auth.auth().signIn(withCustomToken: customToken) { [weak self] result, error in
                    if result != nil, result?.user.uid.isEmpty == false {
                        Auth.auth().currentUser?.getIDToken(completion: { token, error in
                            if let token = token {
                                KeychainService.token = token
                                AppSettings.activated = true
                                let storyboard = UIStoryboard(name: "Active", bundle: nil)
                                AppDelegate.shared.window?.rootViewController = storyboard.instantiateInitialViewController()
                            } else {
                                self?.presentError(error)
                            }
                        })
                    } else {
                        self?.presentError(error)
                    }
                }
            } else {
                self?.presentError(error)
            }
        }
    }

    func presentError(_ error: Error?) {
        let viewModel: ErrorVM
        if let error = error, (error as NSError).domain == NSURLErrorDomain,
           [NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost, NSURLErrorTimedOut].contains((error as NSError).code) {
            viewModel = ErrorVM(
                headline: L10n.errorActivationInternetHeadline,
                text: L10n.errorActivationInternetText,
                actionTitle: L10n.errorActivationInternetTitleAction,
                action: { self.activateApp() }
            )
        } else {
            viewModel = ErrorVM.unknown
        }

        if let errorVC = ErrorVC.instantiateViewController(with: viewModel) {
            present(errorVC, animated: true)
        }
    }

}

extension PrivacyVC: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        openURL(URL: URL)
        return false
    }
}
