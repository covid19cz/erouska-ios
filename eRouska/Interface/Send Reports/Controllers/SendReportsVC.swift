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

final class SendReportsVC: BaseController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasVerificationService & HasDiagnosis

    var dependencies: Dependencies!

    // MARK: -

    private let code = BehaviorRelay<String>(value: "")
    private var isValid: Observable<Bool> {
        code.asObservable().map { phoneNumber -> Bool in
            InputValidation.code.validate(phoneNumber)
        }
    }
    private var keyboardHandler: KeyboardHandler!
    private let disposeBag = DisposeBag()

    private var firstAppear: Bool = true

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var footerLabel: UILabel!
    @IBOutlet private weak var codeTextField: UITextField!

    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var verifyButton: Button!
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

        scrollView.contentInset.bottom = buttonsView.frame.height

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
            let controller = segue.destination as? SendReporting
            controller?.sendReport = sender as? SendReport
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

    @IBAction private func verifyCodeAction() {
        guard let connection = try? Reachability().connection, connection != .unavailable else {
            showAlert(
                title: L10n.dataListSendErrorFailedTitle,
                message: L10n.dataListSendErrorFailedMessage
            )
            return
        }

        view.endEditing(true)
        let verifyCode = code.value

        if let report = AppSettings.sendReport, report.verificationCode == verifyCode, !report.isExpired {
            resultVerify(report)
            return
        }

        verify(verifyCode)

        /*
        // swiftlint:disable:next line_length
        let verificationToken = "eyJhbGciOiJFUzI1NiIsImtpZCI6IjU0NzE0ZWRkLTM3MDktNDJhNy1hZWJjLTJjMzljZjY3ZWY3YSIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJkaWFnbm9zaXMtdmVyaWZpY2F0aW9uLWV4YW1wbGUiLCJleHAiOjE2MTQ2MDA0MTAsImp0aSI6Ii9yMFEwTVVMZzRwRXVxWEhJRVVRTUFQTG1xb3NJZTc0cEE4dHByZGJEQWliY0RIMmZqZGErS1E0TWREVExLaWx4TlUrc2hmaVR0U2hjVEFnWVVQazFUYktzek80bnBqZDk0ZUorZkpWR0lZMGlEazFnMjl2a2UyNkRocGxxSFBaIiwiaWF0IjoxNjE0NTE0MDEwLCJpc3MiOiJkaWFnbm9zaXMtdmVyaWZpY2F0aW9uLWV4YW1wbGUiLCJzdWIiOiJjb25maXJtZWQuLiJ9.dgZFHaeC0tKQHmDTUT8APOFjtGmb6sftHwWo7XVSB34faVZdvDyCKrEhi8kUmI5gagr52Imra1anw0e0Li5s6Q"
        resultVerify(SendReport(verificationCode: verifyCode, verificationToken: verificationToken, verificationTokenDate: Date()))
        */
    }

    @IBAction private func noCodeAction() {
        perform(segue: StoryboardSegue.SendReports.noCode)
    }

    @IBAction private func closeAction() {
        dismiss(animated: true)
    }

    private func resultVerify(_ sendReport: SendReport) {
        AppSettings.sendReport = sendReport
        perform(segue: StoryboardSegue.SendReports.symptoms, sender: sendReport)
    }

    private func resultErrorAction(code: String, message: String? = nil) {
        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.error(code, message))
    }

    private func askForNewCodeAction() {
        if dependencies.diagnosis.canSendMail {
            dependencies.diagnosis.present(fromController: self, screenName: .sendCode, kind: .error(nil))
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
        keyboardHandler = KeyboardHandler(
            in: view,
            scrollView: scrollView,
            buttonsView: buttonsView,
            buttonsBottomConstraint: buttonsBottomConstraint,
            bottomInset: buttonsView.frame.height - 30
        )

        codeTextField.rx.text.orEmpty.bind(to: code).disposed(by: disposeBag)

        isValid.bind(to: verifyButton.rx.isEnabled).disposed(by: disposeBag)
    }

    func setupStrings() {
        title = L10n.dataListSendTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))

        headlineLabel.text = L10n.dataListSendHeadline
        footerLabel.text = L10n.dataListSendFooter(DateFormatter.baseDateFormatter.string(from: AppSettings.lastUploadDate ?? Date()))
        codeTextField.placeholder = L10n.dataListSendPlaceholder
        verifyButton.setTitle(L10n.dataListSendActionTitle)
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

    func verify(_ code: String) {
        reportShowProgress()
        let verificationTokenDate = Date()

        dependencies.verification.verify(with: code) { [weak self] result in
            switch result {
            case .success(let token):
                log("SendReportsVC: code verified, received token \(token)")
                self?.reportHideProgress()
                self?.resultVerify(SendReport(verificationCode: code, verificationToken: token, verificationTokenDate: verificationTokenDate))
            case .failure(let error):
                log("SendReportsVC: Failed to verify code \(error)")
                self?.reportHideProgress()
                self?.showVerifyError(error)
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
