//
//  SendReportsShareVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 26.02.2021.
//

import UIKit
import Reachability
import RxSwift
import RxRelay
import DeviceKit
import FirebaseCrashlytics

final class SendReportsShareVC: BaseController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasExposureService & HasVerificationService & HasReportService & HasDiagnosis

    var dependencies: Dependencies!

    // MARK: -

    var verificationToken: String? = nil
    var traveler: Bool = false
    var shareData: Bool = false

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!

    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var confirmButton: Button!
    @IBOutlet private weak var rejectButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin

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

    // MARK: - Actions

    @IBAction private func confirmAction() {
        shareData = true
        report()
    }

    @IBAction private func rejectAction() {
        shareData = false
        report()
    }

    private func report() {
        guard let connection = try? Reachability().connection, connection != .unavailable else {
            showAlert(
                title: L10n.dataListSendErrorFailedTitle,
                message: L10n.dataListSendErrorFailedMessage
            )
            return
        }

        guard let token = verificationToken else {
            resultErrorAction(code: "777", message: "No verification token")
            return
        }

        report(with: token)
    }

    @IBAction private func closeAction() {
        dismiss(animated: true)
    }

    private func resultAction() {
        log("SendReportsShareVC: result success")
        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.standard)
    }

    private func resultNoKeysAction() {
        log("SendReportsShareVC: result no keys")
        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.noKeys)
    }

    private func resultErrorAction(code: String, message: String? = nil) {
        log("SendReportsShareVC: result error: \(code), \(message ?? "nil")")
        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.error(code, message))
    }

}

private extension SendReportsShareVC {

    // MARK: - Setup

    func setupStrings() {
        title = L10n.dataSendShareTitle

        headlineLabel.text = L10n.dataSendShareHeadline
        bodyLabel.text = L10n.dataSendShareBody
        confirmButton.setTitle(L10n.dataSendShareActionConfirm)
        rejectButton.setTitle(L10n.dataSendShareActionReject)
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

    func report(with token: String) {
        #if DEBUG
        debugAskForTypeOfKeys(token: token)
        #else
        sendReport(with: .normal, token: token)
        #endif
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

        switch type {
        case .test:
            dependencies.exposure.getTestDiagnosisKeys(callback: callback)
        case .normal:
            dependencies.exposure.getDiagnosisKeys(callback: callback)
        }
    }

    func requestCertificate(keys: [ExposureDiagnosisKey], token: String) {
        do {
            let secret = Data.random(count: 32)
            let hmacKey = try dependencies.reporter.calculateHmacKey(keys: keys, secret: secret)
            dependencies.verification.requestCertificate(token: token, hmacKey: hmacKey) { result in
                switch result {
                case .success(let certificate):
                    log("SendReportsShareVC: Certificate \(certificate)")
                    self.uploadKeys(keys: keys, verificationPayload: certificate, hmacSecret: secret)
                case .failure(let error):
                    log("SendReportsShareVC: Failed to get verification payload \(error)")
                    self.reportHideProgress()
                    self.resultErrorAction(code: error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        } catch {
            log("SendReportsShareVC: Failed to get hmac for keys \(error)")
            reportHideProgress()
            resultErrorAction(code: error.localizedDescription)
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func uploadKeys(keys: [ExposureDiagnosisKey], verificationPayload: String, hmacSecret: Data) {
        dependencies.reporter.uploadKeys(
            keys: keys,
            verificationPayload: verificationPayload,
            hmacSecret: hmacSecret,
            efgs: shareData,
            traveler: traveler
        ) { [weak self] result in
            self?.reportHideProgress()
            switch result {
            case .success:
                self?.resultAction()
            case .failure(let error):
                log("SendReportsShareVC: Failed to get upload keys \(error)")
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
            resultErrorAction(code: "\(status.rawValue)-" + code.rawValue, message: error.localizedDescription)
        case let .certificateError(status, code):
            resultErrorAction(code: "\(status.rawValue)-" + code.rawValue, message: error.localizedDescription)
        case let .generalError(status, code):
            resultErrorAction(code: "\(status.rawValue)-" + code, message: error.localizedDescription)
        case .noData:
            resultErrorAction(code: "noData", message: error.localizedDescription)
        }
    }

}
