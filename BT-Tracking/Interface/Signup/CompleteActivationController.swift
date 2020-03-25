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
import RxKeyboard
import FirebaseAuth
import FirebaseFunctions
import DeviceKit

class CompleteActivationController: UIViewController {

    var authData: AccountActivationControler.AuthData?

    private var smsCode = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        smsCode.asObservable().map { phoneNumber -> Bool in
            AccountActivationControler.PhoneValidator.smsCode.validate(phoneNumber)
        }
    }
    private var disposeBag = DisposeBag()

    private lazy var functions = Functions.functions(region:"europe-west2")

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var smsCodeTextField: UITextField!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var activityView: UIView!
    @IBOutlet private weak var smsResendButton: UIButton!

    private var resendSeconds: TimeInterval = 0
    private var resendTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        startResendTimer()

        titleLabel.text = titleLabel.text?.replacingOccurrences(of: "%@", with: authData?.phoneNumber ?? "")

        smsCodeTextField.rx.text.orEmpty.bind(to: smsCode).disposed(by: disposeBag)

        isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)

        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyboardVisibleHeight in
            guard let self = self else { return }

            self.view.setNeedsLayout()
            UIView.animate(withDuration: 0.1) {
                let adjsutHomeIndicator = keyboardVisibleHeight - self.view.safeAreaInsets.bottom
                self.scrollView.contentInset.bottom = adjsutHomeIndicator
                self.scrollView.scrollIndicatorInsets.bottom = adjsutHomeIndicator
                self.view.layoutIfNeeded()
            }
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        smsCodeTextField.becomeFirstResponder()
    }

    // MARK: - Actions

    @IBAction private func activateAcountAction(_ sender: Any) {
        activityView.isHidden = false
        view.endEditing(true)
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: smsCode.value)

        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }

            if let rawError = error {
                let error = rawError as NSError
                self.activityView.isHidden = true

                if error.code == AuthErrorCode.sessionExpired.rawValue {
                    self.showError(
                        title: "Vypršela platnost ověřovacího kódu",
                        message: "Nechte si odeslat nový ověřovací kód a zadejte ho do 3 minut.",
                        okTitle: "Ano, chci",
                        okHandler: { [weak self] in
                            self?.resendSmsCode()
                        },
                        action: (title: "Ne", handler: { [weak self] in
                            self?.smsCodeTextField.becomeFirstResponder()
                            self?.smsResendButton.isEnabled = true
                        })
                    )
                } else {
                    self.show(error: error, title: "Chyba při aktivaci")
                    self.smsCodeTextField.becomeFirstResponder()
                }
            } else {
                var data: [String: Any] = [
                    "platform": "iOS",
                    "platformVersion": UIDevice.current.systemVersion,
                    "manufacturer": "Apple",
                    "model": Device.current.description,
                    "locale": "\(Locale.current.languageCode ?? "cs")_\(Locale.current.regionCode ?? "CZ")",
                ]

                if let token = AppDelegate.delegate.deviceToken {
                    data["pushRegistrationToken"] = token.hexEncodedString()
                } else {
                    data["pushRegistrationToken"] = "hovno"
                }

                self.functions.httpsCallable("registerBuid").call(data) { [weak self] result, error in
                    guard let self = self else { return }
                    self.activityView.isHidden = true

                    if let error = error as NSError? {
                        self.show(error: error, title: "Chyba při aktivaci")
                        self.cleanup()
                        self.navigationController?.popViewController(animated: true)
                    } else if let result = result {
                        if let BUID = (result.data as? [String: Any])?["buid"] as? String {
                            AppSettings.BUID = BUID

                            let storyboard = UIStoryboard(name: "Active", bundle: nil)
                            AppDelegate.delegate.window?.rootViewController = storyboard.instantiateInitialViewController()
                        } else {
                            self.show(error: NSError(domain: FunctionsErrorDomain, code: 500, userInfo: nil), title: "Chyba při aktivaci")
                            self.cleanup()
                        }
                    }

                }
            }
        }
    }

    @IBAction private func resendSmsCode() {
        guard let phone = authData?.phoneNumber else { return }
        activityView.isHidden = false
        smsCodeTextField.resignFirstResponder()

        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            self.activityView.isHidden = true

            if let error = error {
                self.show(error: error, title: "Chyba při aktivaci")
                self.cleanup()
            } else if let verificationID = verificationID  {
                self.authData = AccountActivationControler.AuthData(verificationID: verificationID, phoneNumber: phone)
                self.startResendTimer()
                self.smsCodeTextField.becomeFirstResponder()
            }
        }
    }

    private func startResendTimer() {
        smsResendButton.isEnabled = false
        resendSeconds = 30
        updateResendTitle()

        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.resendSeconds -= 1

            if self.resendSeconds == 0 {
                self.resendTimer?.invalidate()
                self.smsResendButton.isEnabled = true
            } else {
                self.updateResendTitle()
            }
        })
    }

    private func updateResendTitle() {
        guard !smsResendButton.isEnabled else { return }
        UIView.performWithoutAnimation {
            self.smsResendButton.setTitle("Znovu odeslat SMS \(Int(resendSeconds))", for: .disabled)
        }
    }

    private func cleanup() {
        do {
            try Auth.auth().signOut()
        } catch {

        }

        UserDefaults.resetStandardUserDefaults()
    }

}
