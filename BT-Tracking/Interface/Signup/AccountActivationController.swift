//
//  AccountActivationController.swift
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

final class AccountActivationController: UIViewController {

    struct AuthData {
        let verificationID: String
        let phoneNumber: String
    }

    enum PhoneValidator {
        case prefix, number, smsCode

        var characterSet: CharacterSet {
            switch self {
            case .prefix:
                return CharacterSet(charactersIn: "+0123456789")
            case .number, .smsCode:
                return CharacterSet(charactersIn: "0123456789")
            }
        }

        var rangeLimit: ClosedRange<Int> {
            switch self {
            case .prefix:
                return 2...5
            case .number:
                return 9...9
            case .smsCode:
                return 6...6
            }
        }

        func validate(_ text: String) -> Bool {
            guard rangeLimit.contains(text.count), text == filtered(text) else { return false }
            return true
        }

        func filtered(_ text: String) -> String {
            let set = characterSet.inverted
            return text.components(separatedBy: set).joined()
        }

        func checkChange(_ oldString: String, _ newString: String) -> (result: Bool, edited: String?) {
            guard newString.count <= rangeLimit.upperBound else {
                let text = String(filtered(newString).prefix(rangeLimit.upperBound))
                return (result: false, edited: oldString == text ? nil : text)
            }
            return (result: true, edited: nil)
        }
    }

    private var phonePrefix = BehaviorRelay<String>(value: "")
    private var phoneNumber = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        Observable.combineLatest(phonePrefix.asObservable(), phoneNumber.asObservable()).map { (phonePrefix, phoneNumber) -> Bool in
            return PhoneValidator.prefix.validate(phonePrefix) && PhoneValidator.number.validate(phoneNumber)
        }
    }
    private var disposeBag = DisposeBag()

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var phonePrefixTextField: UITextField!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var permissionSwitch: UISwitch!
    @IBOutlet private weak var activityView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        phonePrefixTextField.rx.text.orEmpty.bind(to: phonePrefix).disposed(by: disposeBag)
        phoneNumberTextField.rx.text.orEmpty.bind(to: phoneNumber).disposed(by: disposeBag)

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
                    guard contentSize.height - height > -60 else { return }
                    self.scrollView.scrollRectToVisible(CGRect(x: 0, y: (contentSize.height - height), width: contentSize.width, height: height), animated: true)
                }
            }
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard Device.current.diagonal != 4 else { return }
        phoneNumberTextField.becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let destination = segue.destination as? CompleteActivationController,
            let authData = sender as? AuthData else { return }
        destination.authData = authData
    }

    // MARK: - Actions

    @IBAction private func activateAcountAction() {
        guard permissionSwitch.isOn else {
            self.showError(
                title: "Souhlas s podmínkami zpracování je nezbytný pro aktivaci aplikace. Bez vašeho souhlasu nemůže aplikace fungovat.",
                message: ""
            )
            return
        }

        activityView.isHidden = false
        view.endEditing(true)

        let phone = phonePrefix.value + phoneNumber.value
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            self.activityView.isHidden = true

            if let error = error {
                log("Auth: verifyPhoneNumber error: \(error.localizedDescription)")
                if (error as NSError).code == AuthErrorCode.tooManyRequests.rawValue {
                    self.showError(title: "Telefonní číslo jsme dočasně zablokovali", message: "Několikrát jste zkusili neúspěšně ověřit telefonní číslo. Za chvíli to zkuste znovu.")
                } else {
                    self.showError(title: "Nepodařilo se nám ověřit telefonní číslo", message: "Zkontrolujte připojení k internetu a zkuste to znovu")
                }
                self.cleanup()
            } else if let verificationID = verificationID  {
                self.performSegue(withIdentifier: "verification", sender: AuthData(verificationID: verificationID, phoneNumber: phone))
            }
        }
    }

    @IBAction private func privacyURLAction() {
        guard let url = URL(string: RemoteValues.termsAndConditionsLink) else { return }
        openURL(URL: url)
    }

}

extension AccountActivationController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }

        let type: PhoneValidator
        if textField == phonePrefixTextField {
            type = .prefix
        } else if textField == phoneNumberTextField {
            type = .number
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

private extension AccountActivationController {

    func cleanup() {
        do {
            try Auth.auth().signOut()
        } catch {

        }

        UserDefaults.resetStandardUserDefaults()
    }

}
