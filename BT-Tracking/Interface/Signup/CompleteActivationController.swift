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
import DeviceKit

final class CompleteActivationController: UIViewController {

    var authData: AccountActivationControler.AuthData?

    private var smsCode = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        smsCode.asObservable().map { phoneNumber -> Bool in
            AccountActivationControler.PhoneValidator.smsCode.validate(phoneNumber)
        }
    }
    private var disposeBag = DisposeBag()

    private var subtitle: String = ""

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var smsCodeTextField: UITextField!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var activityView: UIView!

    private var expirationSeconds: TimeInterval = 0
    private var expirationTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        subtitle = subtitleLabel.text ?? ""
        startExpirationTimer()

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

                guard keyboardVisibleHeight > 0 else { return }

                DispatchQueue.main.async {
                    let height = (self.scrollView.frame.height - adjsutHomeIndicator)
                    let contentSize = self.scrollView.contentSize
                    self.scrollView.scrollRectToVisible(CGRect(x: 0, y: contentSize.height - height, width: contentSize.width, height: height), animated: true)
                }
            }
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        smsCodeTextField.becomeFirstResponder()
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
                    data["pushRegistrationToken"] = "hovno"
                }

                AppDelegate.shared.functions.httpsCallable("registerBuid").call(data) { [weak self] result, error in
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
                self.authData = AccountActivationControler.AuthData(verificationID: verificationID, phoneNumber: phone)
                self.startExpirationTimer()
                self.smsCodeTextField.becomeFirstResponder()
            }
        }
    }

}

extension CompleteActivationController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }

        let type: AccountActivationControler.PhoneValidator
        if textField == smsCodeTextField {
            type = .smsCode
        } else {
            return true
        }

        let candidate = NSString(string: text).replacingCharacters(in: range, with: string)
        let check = type.checkChange(text, candidate)
        if check.result {
            return true
        }
        DispatchQueue.main.async {
            textField.text = check.edited ?? text
            textField.sendActions(for: .valueChanged)
        }
        return false
    }

}

private extension CompleteActivationController {

    func startExpirationTimer() {
        expirationSeconds = Date.timeIntervalSinceReferenceDate + RemoteValues.smsTimeoutSeconds
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
