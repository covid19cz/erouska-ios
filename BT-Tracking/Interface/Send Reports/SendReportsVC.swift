//
//  SendReportsVC.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 11/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import Reachability
import RxSwift
import RxRelay
import DeviceKit
import FirebaseCrashlytics

final class SendReportsVC: UIViewController {

    // MARK: -

    private let viewModel = SendReportsVM()

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
    @IBOutlet private weak var codeTextField: UITextField!

    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var actionButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()

        codeTextField.textContentType = .oneTimeCode

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin

        setupTextField()
        setupStrings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if Device.current == .iPhoneSE {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
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

    @IBAction private func sendReportsAction() {
        guard let connection = try? Reachability().connection, connection != .unavailable else {
            showSendDataError()
            return
        }
        view.endEditing(true)
        verifyCode(code.value)
    }

    @IBAction private func resultAction() {
        perform(segue: StoryboardSegue.SendReports.result)
    }

    @IBAction private func closeAction() {
        dismiss(animated: true)
    }

}

extension SendReportsVC: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return validateTextChange(with: .code, textField: textField, changeCharactersIn: range, newString: string)
    }

}

private extension SendReportsVC {

    // MARK: - Setup

    func setupTextField() {
        keyboardHandler = KeyboardHandler(in: view, scrollView: scrollView, buttonsView: buttonsView, buttonsBottomConstraint: buttonsBottomConstraint)

        codeTextField.rx.text.orEmpty.bind(to: code).disposed(by: disposeBag)

        isValid.bind(to: actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    func setupStrings() {
        title = L10n.dataListSendTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))

        headlineLabel.text = L10n.dataListSendHeadline
        codeTextField.placeholder = L10n.dataListSendPlaceholder
        actionButton.setTitle(L10n.dataListSendActionTitle)
    }

    // MARK: - Progress

    func reportShowProgress() {
        showProgress()

        isModalInPresentation = true
        navigationItem.setLeftBarButton(nil, animated: true)
    }

    func reportHideProgress() {
        hideProgress()

        isModalInPresentation = false
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction)), animated: true)
    }

    // MARK: - Reports

    enum ReportType {
        case normal, test
    }

    func verifyCode(_ code: String) {
        reportShowProgress()

        AppDelegate.dependency.verification.verify(with: code) { [weak self] result in
            switch result {
            case .success(let token):
                #if DEBUG
                self?.debugAskForTypeOfKeys(token: token)
                #else
                self?.sendReport(with: .normal, token: token)
                #endif
            case .failure(let error):
                log("DataListVC: Failed to verify code \(error)")
                self?.reportHideProgress()
                self?.showVerifyError(error)
                Crashlytics.crashlytics().record(error: error)
            }
        }
    }

    func debugAskForTypeOfKeys(token: String) {
        let controller = UIAlertController(title: "Který druh klíčů?", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Test Keys", style: .default, handler: { [weak self] _ in
            self?.sendReport(with: .test, token: token)
        }))
        controller.addAction(UIAlertAction(title: "Normal Keys", style: .default, handler: {[weak self]  _ in
            self?.sendReport(with: .normal, token: token)
        }))
        controller.addAction(UIAlertAction(title: L10n.activeBackgroundModeCancel, style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    func sendReport(with type: ReportType, token: String) {
        let callback: ExposureServicing.KeysCallback = { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let keys):
                guard !keys.isEmpty else {
                    self.reportHideProgress()
                    self.resultAction()
                    self.showNoKeysError()
                    return
                }
                self.requestCertificate(keys: keys, token: token)
            case .failure(let error):
                log("DataListVC: Failed to get exposure keys \(error)")
                self.reportHideProgress()

                switch error {
                case .noData:
                    self.resultAction()
                    self.showNoKeysError()
                default:
                    self.showSendDataFrameworkError(code: error.localizedDescription)
                }
                Crashlytics.crashlytics().record(error: error)
            }
        }

        let exposureService = AppDelegate.dependency.exposureService
        switch type {
        case .test:
            exposureService.getTestDiagnosisKeys(callback: callback)
        case .normal:
            exposureService.getDiagnosisKeys(callback: callback)
        }
    }

    func requestCertificate(keys: [ExposureDiagnosisKey], token: String) {
        do {
            let secret = Data.random(count: 32)
            let hmacKey = try AppDelegate.dependency.reporter.calculateHmacKey(keys: keys, secret: secret)
            AppDelegate.dependency.verification.requestCertificate(token: token, hmacKey: hmacKey) { result in
                switch result {
                case .success(let certificate):
                    self.uploadKeys(keys: keys, verificationPayload: certificate, hmacSecret: secret)
                case .failure(let error):
                    log("DataListVC: Failed to get verification payload \(error)")
                    self.reportHideProgress()
                    self.showSendDataError()
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        } catch {
            log("DataListVC: Failed to get hmac for keys \(error)")
            self.reportHideProgress()
            self.showSendDataError()
        }
    }

    func uploadKeys(keys: [ExposureDiagnosisKey], verificationPayload: String, hmacSecret: Data) {
        AppDelegate.dependency.reporter.uploadKeys(
            keys: keys,
            verificationPayload: verificationPayload,
            hmacSecret: hmacSecret) { [weak self] result in
            self?.reportHideProgress()
            switch result {
            case .success:
                self?.resultAction()
            case .failure:
                self?.showSendDataError()
            }
        }
    }

    func showVerifyError(_ error: VerificationError) {
        switch error {
        case let .tokenError(status, code):
            switch code {
            case .codeInvalid:
                showAlert(
                    title: L10n.dataListSendErrorWrongCodeTitle,
                    okHandler: { [weak self] in
                        self?.codeTextField.text = nil
                        self?.codeTextField.becomeFirstResponder()
                    }
                )
            case .codeExpired, .codeNotFound:
                showAlert(
                    title: L10n.dataListSendErrorExpiredCodeTitle,
                    message: L10n.dataListSendErrorExpiredCodeMessage,
                    okHandler: { [weak self] in
                        self?.codeTextField.text = nil
                        self?.codeTextField.becomeFirstResponder()
                    }
                )
            default:
                showAlert(
                    title: L10n.dataListSendErrorTitle,
                    message: L10n.dataListSendErrorMessage("\(status.rawValue)-" + code.rawValue)
                )
            }
        case let .certificateError(status, code):
            showAlert(
                title: L10n.dataListSendErrorTitle,
                message: L10n.dataListSendErrorMessage("\(status.rawValue)-" + code.rawValue)
            )
        case let .generalError(status, code):
            showAlert(
                title: L10n.dataListSendErrorTitle,
                message: L10n.dataListSendErrorMessage("\(status.rawValue)-" + code)
            )
        case .noData:
            showAlert(
                title: L10n.dataListSendErrorTitle,
                message: L10n.dataListSendErrorMessage("noData")
            )
        }
    }

    func showNoKeysError() {
        showAlert(title: L10n.dataListSendErrorNoKeys)
    }

    func showSendDataFrameworkError(code: String) {
        showAlert(
            title: L10n.dataListSendErrorFrameworkTitle,
            message: L10n.dataListSendErrorFrameworkMessage(code)
        )
    }

    func showSendDataError() {
        showAlert(
            title: L10n.dataListSendErrorFailedTitle,
            message: L10n.dataListSendErrorFailedMessage
        )
    }

}
