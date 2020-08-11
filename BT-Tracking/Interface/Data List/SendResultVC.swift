//
//  SendResultVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 20/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import Reachability

final class SendResultVC: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var closeButton: Button!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.localizedTitle("data_send_title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))

        titleLabel.localizedText("data_send_title_label")
        headlineLabel.localizedText("data_send_headline")
        bodyLabel.localizedText("data_send_body")
        closeButton.localizedTitle("data_send_close_button")
    }

    // MARK: - Actions

    @IBAction private func closeAction() {
        dismiss(animated: true)
    }

}

private extension SendResultVC {

    // MARK: - Reports

    enum ReportType {
        case real, test
    }

    func sendReport() {
        #if DEBUG
        #else
        guard (AppSettings.lastUploadDate ?? Date.distantPast) + RemoteValues.uploadWaitingMinutes < Date() else {
            showAlert(title: viewModel.sendDataErrorWait)
            return
        }
        #endif

        guard let connection = try? Reachability().connection, connection != .unavailable else {
            showSendDataErrorFailed()
            return
        }

        let controller = UIAlertController(title: "", message: "", preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "Verification Code"
            textField.keyboardType = .numberPad
            textField.returnKeyType = .done
        }
        controller.addAction(UIAlertAction(title: NSLocalizedString("Verify", comment: ""), style: .default, handler: { [weak self] _ in
            self?.verifyCode(controller.textFields?.first?.text ?? "")
        }))
        controller.addAction(UIAlertAction(title: NSLocalizedString("active_background_mode_cancel", comment: ""), style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    func verifyCode(_ code: String) {
        showProgress()
        AppDelegate.dependency.verification.verify(with: code) { [weak self] result in
            switch result {
            case .success(let token):
                self?.askForTypeOfKeys(token: token)
            case .failure(let error):
                log("DataListVC: Failed to verify code \(error)")
                self?.hideProgress()
                self?.showSendDataErrorFailed()
            }
        }
    }

    func askForTypeOfKeys(token: String) {
        let controller = UIAlertController(title: "Ktery druh klicu?", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Test keys", style: .default, handler: { [weak self] _ in
            self?.sendReport(with: .test, token: token)
        }))
        controller.addAction(UIAlertAction(title: "Keys", style: .default, handler: {[weak self]  _ in
            self?.sendReport(with: .real, token: token)
        }))
        controller.addAction(UIAlertAction(title: NSLocalizedString("active_background_mode_cancel", comment: ""), style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    func sendReport(with type: ReportType, token: String) {
        let verificationService = AppDelegate.dependency.verification
        let reportService = AppDelegate.dependency.reporter
        let exposureService = AppDelegate.dependency.exposureService
        let callback: ExposureServicing.KeysCallback = { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let keys):
                do {
                    let secret = Data.random(count: 32)
                    let hmacKey = try reportService.calculateHmacKey(keys: keys, secret: secret)
                    verificationService.requestCertificate(token: token, hmacKey: hmacKey) { result in
                        switch result {
                        case .success(let certificate):
                            self.uploadKeys(keys: keys, verificationPayload: certificate, hmacSecret: secret)
                        case .failure(let error):
                            log("DataListVC: Failed to get verification payload \(error)")
                            self.hideProgress()
                            self.showSendDataErrorFailed()
                        }
                    }
                } catch {
                    log("DataListVC: Failed to get hmac for keys \(error)")
                    self.hideProgress()
                    self.showSendDataErrorFailed()
                }
            case .failure(let error):
                log("DataListVC: Failed to get exposure keys \(error)")
                self.hideProgress()
                self.showSendDataErrorFailed()
            }
        }

        switch type {
        case .test:
            exposureService.getTestDiagnosisKeys(callback: callback)
        case .real:
            exposureService.getDiagnosisKeys(callback: callback)
        }
    }

    func uploadKeys(keys: [ExposureDiagnosisKey], verificationPayload: String, hmacSecret: Data) {
        AppDelegate.dependency.reporter.uploadKeys(keys: keys, verificationPayload: verificationPayload, hmacSecret: hmacSecret, callback: { [weak self] result in
            self?.hideProgress()
            switch result {
            case .success:
                self?.performSegue(withIdentifier: "sendReport", sender: nil)
            case .failure:
                self?.showSendDataErrorFailed()
            }
        })
    }

    func showDownloadDataErrorFailed(_ error: Error) {
        show(error: error)
    }

    func showSendDataErrorFailed() {
        /*showAlert(
            title: viewModel.sendDataErrorFailedTitle,
            message: viewModel.sendDataErrorFailedMessage
        )*/
    }

}
