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

final class CompleteActivationController: UIViewController {

    var authData: AccountActivationController.AuthData?

    private var smsCode = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        smsCode.asObservable().map { phoneNumber -> Bool in
            InputValidation.smsCode.validate(phoneNumber)
        }
    }
    private var keyboardHandler: KeyboardHandler!
    private var disposeBag = DisposeBag()

    private var subtitle: String = ""

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var smsCodeTextField: UITextField!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var activityView: UIView!

    private var expirationSeconds: TimeInterval = 0
    private var expirationTimer: Timer?
    private var firstAppear: Bool = true

    deinit {
        expirationTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardHandler = KeyboardHandler(in: view, scrollView: scrollView, buttonsView: buttonsView, buttonsBottomConstraint: buttonsBottomConstraint)

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin

        titleLabel.text = titleLabel.text?.replacingOccurrences(of: "%@", with: authData?.phoneNumber.phoneFormatted ?? "")

        subtitle = subtitleLabel.text ?? ""
        startExpirationTimer()

        smsCodeTextField.rx.text.orEmpty.bind(to: smsCode).disposed(by: disposeBag)

        isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if firstAppear {
            keyboardHandler.setup()
            smsCodeTextField.becomeFirstResponder()
            firstAppear = false
        }
    }

    // MARK: - Actions

    @IBAction private func activateAcountAction(_ sender: Any) {
        guard let authData = authData else { return }
        activityView.isHidden = false
        view.endEditing(true)

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: authData.verificationID, verificationCode: smsCode.value)

        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }

            if let rawError = error {
                let error = rawError as NSError
                self.activityView.isHidden = true

                if error.code == AuthErrorCode.invalidVerificationCode.rawValue {
                    self.smsCodeTextField.text = ""
                    self.showError(title: "Ověřovací kód není správně zadaný.", message: "")
                } else if error.code == AuthErrorCode.sessionExpired.rawValue {
                    self.smsCodeTextField.text = ""
                    self.showError(
                        title: "Vypršela platnost ověřovacího kódu",
                        message: "Nechte si odeslat nový ověřovací kód a zadejte ho do 3 minut.",
                        okTitle: "Ano, chci",
                        okHandler: { [weak self] in
                            self?.resendSmsCode()
                        },
                        action: (title: "Ne", handler: { [weak self] in
                            self?.smsCodeTextField.becomeFirstResponder()
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

                if let token = AppDelegate.shared.deviceToken {
                    data["pushRegistrationToken"] = token.hexEncodedString()
                } else {
                    data["pushRegistrationToken"] = "xyz"
                }

                AppDelegate.shared.functions.httpsCallable("registerBuid").call(data) { [weak self] result, error in
                    guard let self = self else { return }
                    self.activityView.isHidden = true

                    if let error = error as NSError? {
                        self.show(error: error, title: "Chyba při aktivaci")
                        self.cleanup()
                        self.navigationController?.popViewController(animated: true)
                    } else if let result = result?.data as? [String: Any] {
                        if let BUID = result["buid"] as? String,
                            let TUIDs = result["tuids"] as? [String] {
                            KeychainService.BUID = BUID
                            KeychainService.TUIDs = TUIDs

                            let storyboard = UIStoryboard(name: "Active", bundle: nil)
                            AppDelegate.shared.window?.rootViewController = storyboard.instantiateInitialViewController()
                        } else {
                            self.show(error: NSError(domain: AuthErrorDomain, code: 500, userInfo: nil), title: "Chyba při aktivaci")
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
                self.authData = AccountActivationController.AuthData(verificationID: verificationID, phoneNumber: phone)
                self.startExpirationTimer()
                self.smsCodeTextField.becomeFirstResponder()
            }
        }
    }

}

extension CompleteActivationController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let type: InputValidation
        if textField == smsCodeTextField {
             type = .smsCode
        } else {
             return true
        }

        return validateTextChange(with: type, textField: textField, changeCharactersIn: range, newString: string)
    }

}

private extension CompleteActivationController {

    func startExpirationTimer() {
        expirationSeconds = Date.timeIntervalSinceReferenceDate + RemoteValues.smsErrorTimeoutSeconds
        updateExpirationTitle()

        expirationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if self.expirationSeconds - Date.timeIntervalSinceReferenceDate <= 0 {
                self.expirationTimer?.invalidate()
                self.showError(
                    title: "Vypršela platnost ověřovacího kódu",
                    message: "Zkontrolujte telefonní číslo a nechte si odeslat nový ověřovací kód.",
                    okHandler: {
                        self.navigationController?.popViewController(animated: true)
                    }
                )
                return
            }
            self.updateExpirationTitle()
        })
    }

    func updateExpirationTitle() {
        let date = Date(timeIntervalSinceReferenceDate: expirationSeconds - Date.timeIntervalSinceReferenceDate)
        subtitleLabel.text = subtitle.replacingOccurrences(of: "%@", with: dateForamtter.string(from: date))
    }

    var dateForamtter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "m:ss"
        return dateFormatter
    }

    func cleanup() {
        do {
            try Auth.auth().signOut()
        } catch {

        }

        UserDefaults.resetStandardUserDefaults()
    }

}
