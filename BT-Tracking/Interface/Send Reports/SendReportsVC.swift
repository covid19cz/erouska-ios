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

    private let code = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        code.asObservable().map { phoneNumber -> Bool in
            InputValidation.code.validate(phoneNumber)
        }
    }
    private var keyboardHandler: KeyboardHandler!
    private let disposeBag = DisposeBag()

    private var firstAppear: Bool = true

    private var diagnosis: Diagnosis?

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var footerLabel: UILabel!
    @IBOutlet private weak var codeTextField: UITextField!

    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var noCodeButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()

        if Device.current.diagonal < 4.1 {
            navigationItem.largeTitleDisplayMode = .never
        }

        codeTextField.textContentType = .oneTimeCode
        footerLabel.isHidden = AppSettings.lastUploadDate == nil

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin

        scrollView.contentInset.bottom = 20

        setupTextField()
        setupStrings()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch StoryboardSegue.SendReports(segue) {
        case .result:
            let controller = segue.destination as? SendResultVC
            controller?.viewModel = sender as? SendResultVM ?? .standard
        default:
            break
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
            showAlert(
                title: L10n.dataListSendErrorFailedTitle,
                message: L10n.dataListSendErrorFailedMessage
            )
            return
        }
        view.endEditing(true)
        verifyCode(code.value)
    }

    @IBAction private func noCodeAction() {
        perform(segue: StoryboardSegue.SendReports.noCode)
    }

    @IBAction private func closeAction() {
        dismiss(animated: true)
    }

    private func resultAction() {
        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.standard)
    }

    private func resultNoKeysAction() {
        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.noKeys)
    }

    private func resultErrorAction(code: String, message: String? = nil) {
        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.error(code, message))
    }

    private func askForNewCodeAction() {
        if Diagnosis.canSendMail {
            diagnosis = Diagnosis(showFromController: self, screenName: .sendCode, kind: .error(nil))
        } else if let URL = URL(string: "mailto:info@erouska.cz") {
            openURL(URL: URL)
        }
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
        footerLabel.text = L10n.dataListSendFooter(DateFormatter.baseDateFormatter.string(from: AppSettings.lastUploadDate ?? Date()))
        codeTextField.placeholder = L10n.dataListSendPlaceholder
        actionButton.setTitle(L10n.dataListSendActionTitle)
        noCodeButton.setTitle(L10n.dataListSendNoCodeActionTitle)
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
                    self.resultNoKeysAction()
                    return
                }
                self.requestCertificate(keys: keys, token: token)
            case .failure(let error):
                log("DataListVC: Failed to get exposure keys \(error)")
                self.reportHideProgress()

                switch error {
                case .noData:
                    self.resultNoKeysAction()
                default:
                    self.resultErrorAction(code: error.localizedDescription)
                }
                Crashlytics.crashlytics().record(error: error)
            }
        }

        let exposureService = AppDelegate.dependency.exposure
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
                    self.resultErrorAction(code: error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        } catch {
            log("DataListVC: Failed to get hmac for keys \(error)")
            reportHideProgress()
            resultErrorAction(code: error.localizedDescription)
            Crashlytics.crashlytics().record(error: error)
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
            case .failure(let error):
                if let error = error as? ReportUploadError {
                    switch error {
                    case .upload(let code, let message):
                        self?.resultErrorAction(code: code, message: message)
                    }
                } else {
                    self?.resultErrorAction(code: error.localizedDescription)
                }
                Crashlytics.crashlytics().record(error: error)
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
                    },
                    action: (L10n.dataListSendErrorExpiredCodeAction, { [weak self] in self?.askForNewCodeAction() })
                )
            default:
                resultErrorAction(code: "\(status.rawValue)-" + code.rawValue, message: error.localizedDescription)
            }
        case let .certificateError(status, code):
            resultErrorAction(code: "\(status.rawValue)-" + code.rawValue, message: error.localizedDescription)
        case let .generalError(status, code):
            resultErrorAction(code: "\(status.rawValue)-" + code, message: error.localizedDescription)
        case .noData:
            resultErrorAction(code: "noData", message: error.localizedDescription)
        }
    }

}
