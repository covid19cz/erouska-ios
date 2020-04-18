//
//  CompleteActivation.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseAuth
import DeviceKit

final class CompleteActivationVC: UIViewController {

    var authData: AccountActivationVC.AuthData?

    // MARK: -

    private let viewModel = CompleteActivationVM()

    private var code = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        code.asObservable().map { phoneNumber -> Bool in
            InputValidation.code.validate(phoneNumber)
        }
    }
    private var keyboardHandler: KeyboardHandler!
    private var disposeBag = DisposeBag()

    private var expirationSeconds: TimeInterval = 0
    private var expirationTimer: Timer?

    private var firstAppear: Bool = true

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var codeTextField: UITextField!

    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var actionButton: Button!

    // MARK: -

    deinit {
        expirationTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin

        setupTextField()
        setupStrings()

        startExpirationTimer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if firstAppear {
            keyboardHandler.setup()
            codeTextField.becomeFirstResponder()
            firstAppear = false
        }
    }

    // MARK: - Actions

    @IBAction private func activateAcountAction(_ sender: Any) {
        guard let authData = authData else { return }

        showProgress()
        view.endEditing(true)

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: authData.verificationID, verificationCode: code.value)

        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                self.hideProgress()
                self.handleVerification(error: error as NSError)
            } else {
                self.handleSuccess()
            }
        }
    }

    @IBAction private func resendCode() {
        guard let phone = authData?.phoneNumber else { return }

        showProgress()
        codeTextField.resignFirstResponder()

        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            self.hideProgress()

            if let error = error {
                self.handle(error: error)
            } else if let verificationID = verificationID  {
                self.authData = AccountActivationVC.AuthData(verificationID: verificationID, phoneNumber: phone)
                self.startExpirationTimer()
                self.codeTextField.becomeFirstResponder()
            }
        }
    }

}

extension CompleteActivationVC: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let type: InputValidation
        if textField == codeTextField {
             type = .code
        } else {
             return true
        }

        return validateTextChange(with: type, textField: textField, changeCharactersIn: range, newString: string)
    }

}

private extension CompleteActivationVC {

    func setupTextField() {
        keyboardHandler = KeyboardHandler(in: view, scrollView: scrollView, buttonsView: buttonsView, buttonsBottomConstraint: buttonsBottomConstraint)

        codeTextField.rx.text.orEmpty.bind(to: code).disposed(by: disposeBag)

        isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.help)

        headlineLabel.localizedText(viewModel.headline, values: authData?.phoneNumber.phoneFormatted ?? "")
        updateExpirationTitle()
        codeTextField.localizedPlaceholder(viewModel.codePlaceholder)
        actionButton.localizedTitle(viewModel.continueButton)
    }

    func startExpirationTimer() {
        expirationSeconds = Date.timeIntervalSinceReferenceDate + RemoteValues.smsErrorTimeoutSeconds
        updateExpirationTitle()

        expirationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }

            if self.expirationSeconds - Date.timeIntervalSinceReferenceDate <= 0 {
                self.expirationTimer?.invalidate()
                self.expirationAlert()
                return
            }
            self.updateExpirationTitle()
        })
    }

    func updateExpirationTitle() {
        let date = Date(timeIntervalSinceReferenceDate: expirationSeconds - Date.timeIntervalSinceReferenceDate)
        bodyLabel.localizedText(viewModel.body, values: dateForamtter.string(from: date))
    }

    var dateForamtter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "m:ss"
        return dateFormatter
    }

    func expirationAlert() {
        showAlert(
            title: viewModel.errorExpiredTitle,
            message: viewModel.errorExpiredMessage,
            okHandler: {
                self.navigationController?.popViewController(animated: true)
            }
        )
    }

    func handleVerification(error: NSError) {
        if error.code == AuthErrorCode.invalidVerificationCode.rawValue {
            codeTextField.text = ""
            showAlert(title: viewModel.errorWrongCode, message: "")
        } else if error.code == AuthErrorCode.sessionExpired.rawValue {
            expirationAlert()
        } else {
            show(error: error, title: viewModel.errorTitle)
            codeTextField.becomeFirstResponder()
        }
    }

    func handle(error: Error) {
        show(error: error, title: viewModel.errorTitle)
        cleanup()
    }

    func handleSuccess() {
        var data: [String: Any] = [
            "platform": "iOS",
            "platformVersion": UIDevice.current.systemVersion,
            "manufacturer": "Apple",
            "model": Device.current.description,
            "locale": "\(Locale.current.languageCode ?? "cs")_\(Locale.current.regionCode ?? "CZ")",
        ]

        if let token = AppDelegate.shared.deviceToken {
            data["pushRegistrationToken"] = token.hexEncodedString()
        } else {
            data["pushRegistrationToken"] = "xyz"
        }

        AppDelegate.shared.functions.httpsCallable("registerBuid").call(data) { [weak self] result, error in
            guard let self = self else { return }
            self.hideProgress()

            if let error = error as NSError? {
                self.handle(error: error)
                self.navigationController?.popViewController(animated: true)
            } else if let result = result?.data as? [String: Any] {
                if let BUID = result["buid"] as? String,
                    let TUIDs = result["tuids"] as? [String] {
                    KeychainService.BUID = BUID
                    KeychainService.TUIDs = TUIDs

                    let storyboard = UIStoryboard(name: "Active", bundle: nil)
                    AppDelegate.shared.window?.rootViewController = storyboard.instantiateInitialViewController()
                } else {
                    self.handle(error: NSError(domain: AuthErrorDomain, code: 500, userInfo: nil))
                }
            }
        }
    }

    func cleanup() {
        do {
            try Auth.auth().signOut()
        } catch {

        }

        UserDefaults.resetStandardUserDefaults()
    }

}
