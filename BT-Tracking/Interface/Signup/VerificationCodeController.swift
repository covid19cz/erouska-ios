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

protocol VerificationCodeControllerDelegate: AnyObject {
    func controller(_ controller: VerificationCodeController, didTapVerifyWithCode code: String)
    func controllerDidTapRetry(_ controller: VerificationCodeController)
    func controllerDidTapHelp(_ controller: VerificationCodeController)
}

protocol HandlingVerificationCodeErrors: AnyObject & UIViewController {
    func handleError(_ error: VerificationCodeError)
}

final class VerificationCodeController: UIViewController {

    // MARK: - Public Properties

    var phoneNumber: String?
    weak var delegate: VerificationCodeControllerDelegate?

    // MARK: - Private Properties

    private let smsCode = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        smsCode.asObservable().map {
            InputValidation.smsCode.validate($0)
        }
    }
    private var keyboardHandler: KeyboardHandler!
    private let disposeBag = DisposeBag()

    private var subtitle: String = ""

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var smsCodeTextField: UITextField!
    @IBOutlet private weak var actionButton: Button!

    private var expirationSeconds: TimeInterval = 0
    private var expirationTimer: Timer?
    private var firstAppear = true

    // MARK: - Lifecycle

    deinit {
        expirationTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Nápověda", style: .plain, target: self, action: #selector(didTapHelp))

        keyboardHandler = KeyboardHandler(in: view, scrollView: scrollView, buttonsView: buttonsView, buttonsBottomConstraint: buttonsBottomConstraint)

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin

        titleLabel.text = titleLabel.text?.replacingOccurrences(of: "%@", with: phoneNumber?.phoneFormatted ?? "")

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

    @IBAction private func didTapVerify(_ sender: Any) {
        delegate?.controller(self, didTapVerifyWithCode: smsCode.value)
        view.endEditing(true)
    }

    @objc private func didTapHelp() {
        delegate?.controllerDidTapHelp(self)
    }
}

// MARK: - HandlingVerificationCodeErrors

extension VerificationCodeController: HandlingVerificationCodeErrors {

    func handleError(_ error: VerificationCodeError) {
        switch error {
        case .invalid:
            smsCodeTextField.text = ""
            showError(title: "Ověřovací kód není správně zadaný.", message: "")
        case .expired:
            smsCodeTextField.text = ""

            // TODO: Add finish registration later option
            self.showError(
                title: "Vypršela platnost ověřovacího kódu",
                message: "Zkontrolujte telefonní číslo a nechte si odeslat nový ověřovací kód.",
                okHandler: { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.controllerDidTapRetry(self)
                }
            )
        case .general:
            show(error: error, title: "Chyba při aktivaci")
            smsCodeTextField.becomeFirstResponder()
        }
    }
}

// MARK: - UITextFieldDelegate

extension VerificationCodeController: UITextFieldDelegate {

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

private extension VerificationCodeController {

    func startExpirationTimer() {
        expirationSeconds = Date.timeIntervalSinceReferenceDate + RemoteValues.smsErrorTimeoutSeconds
        updateExpirationTitle()

        expirationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }

            if self.expirationSeconds - Date.timeIntervalSinceReferenceDate <= 0 {
                self.expirationTimer?.invalidate()
                self.showError(
                    title: "Vypršela platnost ověřovacího kódu",
                    message: "Zkontrolujte telefonní číslo a nechte si odeslat nový ověřovací kód.",
                    okHandler: { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.controllerDidTapRetry(self)
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
}
