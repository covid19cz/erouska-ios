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
import FirebaseAuth
import DeviceKit

final class AccountActivationController: UIViewController {

    struct AuthData {
        let verificationID: String
        let phoneNumber: String
    }

    private var phonePrefix = BehaviorRelay<String>(value: "")
    private var phoneNumber = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        Observable.combineLatest(phonePrefix.asObservable(), phoneNumber.asObservable()).map { (phonePrefix, phoneNumber) -> Bool in
            return InputValidation.prefix.validate(phonePrefix) && InputValidation.number.validate(phoneNumber)
        }
    }
    private var keyboardHandler: KeyboardHandler!
    private var disposeBag = DisposeBag()

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var phonePrefixTextField: UITextField!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var permissionSwitch: UISwitch!
    @IBOutlet private weak var activityView: UIView!

    private var firstAppear: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardHandler = KeyboardHandler(in: view, scrollView: scrollView, buttonsView: buttonsView, buttonsBottomConstraint: buttonsBottomConstraint)

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin
        
        phonePrefixTextField.rx.text.orEmpty.bind(to: phonePrefix).disposed(by: disposeBag)
        phoneNumberTextField.rx.text.orEmpty.bind(to: phoneNumber).disposed(by: disposeBag)

        isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if firstAppear {
            keyboardHandler.setup()
        }
        guard Device.current.diagonal != 4 else {
            firstAppear = false
            return
        }

        if firstAppear {
            phoneNumberTextField.becomeFirstResponder()
            firstAppear = false
        }
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
        let type: InputValidation
        if textField == phonePrefixTextField {
            type = .prefix
        } else if textField == phoneNumberTextField {
            type = .number
        } else {
            return true
        }

        return validateTextChange(with: type, textField: textField, changeCharactersIn: range, newString: string)
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
