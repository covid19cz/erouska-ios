//
//  AccountActivationVC.swift
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

final class AccountActivationVC: UIViewController {

    struct AuthData {
        let verificationID: String
        let phoneNumber: String
    }

    // MARK: -

    private let viewModel = AccountActivationVM()

    private var phonePrefix = BehaviorRelay<String>(value: "")
    private var phoneNumber = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        Observable.combineLatest(phonePrefix.asObservable(), phoneNumber.asObservable()).map { (phonePrefix, phoneNumber) -> Bool in
            return InputValidation.prefix.validate(phonePrefix) && InputValidation.number.validate(phoneNumber)
        }
    }
    private var keyboardHandler: KeyboardHandler!
    private var disposeBag = DisposeBag()

    private var firstAppear: Bool = true

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var phonePrefixTextField: UITextField!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var permissionTitleLabel: UILabel!
    @IBOutlet private weak var permissionSwitch: UISwitch!
    @IBOutlet private weak var permissionFooter: UILabel!
    @IBOutlet private weak var permissionMoreButton: UIButton!

    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var actionButton: UIButton!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin

        setupTextFields()
        setupStrings()
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

        guard let destination = segue.destination as? CompleteActivationVC,
            let authData = sender as? AuthData else { return }
        destination.authData = authData
    }

    // MARK: - Actions

    @IBAction private func activateAcountAction() {
        guard permissionSwitch.isOn else {
            self.showAlert(title: viewModel.permissionAlert)
            return
        }

        showProgress()
        view.endEditing(true)

        let phone = phonePrefix.value + phoneNumber.value
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            self.hideProgress()

            if let error = error {
                self.handle(error: error)
            } else if let verificationID = verificationID  {
                self.handleSuccess(authData: AuthData(verificationID: verificationID, phoneNumber: phone))
            }
        }
    }

    @IBAction private func privacyURLAction() {
        guard let url = URL(string: RemoteValues.termsAndConditionsLink) else { return }
        openURL(URL: url)
    }

}

extension AccountActivationVC: UITextFieldDelegate {

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

private extension AccountActivationVC {

    func setupStrings() {
        navigationItem.localizedTitle(viewModel.title)
        navigationItem.backBarButtonItem?.localizedTitle(viewModel.back)
        navigationItem.rightBarButtonItem?.localizedTitle(viewModel.help)

        headlineLabel.localizedText(viewModel.headline)
        phonePrefixTextField.localizedPlaceholder(viewModel.phonePrefix)
        phonePrefixTextField.localizedText(viewModel.phonePrefix)
        phoneNumberTextField.localizedPlaceholder(viewModel.phonePlaceholder)
        permissionTitleLabel.localizedText(viewModel.permissionTitle)
        permissionFooter.localizedText(viewModel.permissionFooter)
        permissionMoreButton.localizedTitle(viewModel.permissionFooterMore)
        actionButton.localizedTitle(viewModel.continueButton)
    }

    func setupTextFields() {
        keyboardHandler = KeyboardHandler(in: view, scrollView: scrollView, buttonsView: buttonsView, buttonsBottomConstraint: buttonsBottomConstraint)

        phonePrefixTextField.rx.text.orEmpty.bind(to: phonePrefix).disposed(by: disposeBag)
        phoneNumberTextField.rx.text.orEmpty.bind(to: phoneNumber).disposed(by: disposeBag)

        isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    func handle(error: Error) {
        log("Auth: verifyPhoneNumber error: \(error.localizedDescription)")
        if (error as NSError).code == AuthErrorCode.tooManyRequests.rawValue {
            showAlert(
                title: viewModel.errorToManyRequestsTitle,
                message: viewModel.errorToManyRequestsMessage
            )
        } else {
            showAlert(
                title: viewModel.errorVerificationTitle,
                message: viewModel.errorVerificationMessage
            )
        }
        cleanup()
    }

    func handleSuccess(authData: AuthData) {
        performSegue(withIdentifier: "verification", sender: authData)
    }

    func cleanup() {
        do {
            try Auth.auth().signOut()
        } catch {

        }

        UserDefaults.resetStandardUserDefaults()
    }

}
