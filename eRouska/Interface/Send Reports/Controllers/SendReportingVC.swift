//
//  SendReportingVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 28.02.2021.
//

import UIKit
import Reachability
import RxSwift
import RxRelay
import DeviceKit
import FirebaseCrashlytics

protocol SendReporting: UIViewController {

    var sendReport: SendReport? { get set }

}

class SendReportingVC: BaseController, SendReporting, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasExposureService & HasVerificationService & HasReportService & HasDiagnosis

    var dependencies: Dependencies!

    // MARK: -

    var sendReport: SendReport?

    func report() {
        guard let connection = try? Reachability().connection, connection != .unavailable else {
            showAlert(
                title: L10n.dataListSendErrorFailedTitle,
                message: L10n.dataListSendErrorFailedMessage
            )
            return
        }

        guard let token = sendReport?.verificationToken else {
            resultErrorAction(code: "777", message: "No verification token")
            return
        }

        showProgress()
        report(with: token)
    }

    private func resultAction() {
        log("SendReportsShareVC: result success")
        AppSettings.sendReport = nil

        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.standard)
    }

    private func resultNoKeysAction() {
        log("SendReportsShareVC: result no keys")
        AppSettings.sendReport = nil

        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.noKeys)
    }

    private func resultErrorAction(code: String, message: String? = nil) {
        log("SendReportsShareVC: result error: \(code), \(message ?? "nil")")
        perform(segue: StoryboardSegue.SendReports.result, sender: SendResultVM.error(code, message))
    }

}

private extension SendReportingVC {

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
        controller.addAction(UIAlertAction(title: "Normal Keys", style: .default, handler: { [weak self]  _ in
            self?.sendReport(with: .normal, token: token)
        }))
        controller.addAction(UIAlertAction(title: L10n.activeBackgroundModeCancel, style: .cancel, handler: { [weak self] _ in
            self?.hideProgress()
        }))
        present(controller, animated: true, completion: nil)
    }

    func sendReport(with type: ReportType, token: String) {
        let callback: ExposureServicing.KeysCallback = { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let keys):
                guard !keys.isEmpty else {
                    self.hideProgress()
                    self.resultNoKeysAction()
                    return
                }
                self.requestCertificate(keys: keys, token: token)
            case .failure(let error):
                log("DataListVC: Failed to get exposure keys \(error)")
                self.hideProgress()

                switch error {
                case .noData:
                    self.resultNoKeysAction()
                    return
                case let .exposureError(code):
                    if code == .notAuthorized {
                        // user denied
                        return
                    } else {
                        self.resultErrorAction(code: error.localizedDescription)
                    }
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
                    self.hideProgress()
                    self.resultErrorAction(code: error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        } catch {
            log("SendReportsShareVC: Failed to get hmac for keys \(error)")
            hideProgress()
            resultErrorAction(code: error.localizedDescription)
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func uploadKeys(keys: [ExposureDiagnosisKey], verificationPayload: String, hmacSecret: Data) {
        dependencies.reporter.uploadKeys(
            keys: keys,
            verificationPayload: verificationPayload,
            hmacSecret: hmacSecret,
            traveler: sendReport?.traveler ?? false,
            consentToFederation: sendReport?.consentToFederation ?? false,
            symptomsDate: sendReport?.symptomsDate
        ) { [weak self] result in
            self?.hideProgress()
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
