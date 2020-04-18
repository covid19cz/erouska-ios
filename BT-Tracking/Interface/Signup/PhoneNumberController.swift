//
//  PhoneNumberController.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 19/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import DeviceKit

protocol PhoneNumberControllerDelegate: AnyObject {
    func controllerDidTapPrivacy(_ controller: PhoneNumberController)
    func controller(_ controller: PhoneNumberController, didTapContinueWithPhoneNumber phoneNumber: String)
}

final class PhoneNumberController: UIViewController {

    struct AuthData {
        let verificationID: String
        let phoneNumber: String
    }

    // MARK: - Public Properties

    weak var delegate: PhoneNumberControllerDelegate?

    // MARK: - Private Properties

    private let phonePrefix = BehaviorRelay<String>(value: "")
    private let phoneNumber = BehaviorRelay<String>(value: "")
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

    @IBAction private func didTapContinue() {
        guard permissionSwitch.isOn else {
            self.showError(
                title: "Souhlas s podmínkami zpracování je nezbytný pro aktivaci aplikace. Bez vašeho souhlasu nemůže aplikace fungovat.",
                message: ""
            )
            return
        }

        view.endEditing(true)

        let phone = phonePrefix.value + phoneNumber.value
        delegate?.controller(self, didTapContinueWithPhoneNumber: phone)
    }

    @IBAction private func didTapPrivacy() {
        delegate?.controllerDidTapPrivacy(self)
    }

}

// MARK: - UITextFieldDelegate

extension PhoneNumberController: UITextFieldDelegate {

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
