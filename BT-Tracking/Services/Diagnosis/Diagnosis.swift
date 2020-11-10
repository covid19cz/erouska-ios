//
//  Diagnosis.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 03/11/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import DeviceKit
import MessageUI
import Reachability

class Diagnosis: NSObject {

    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

    private weak var showFromController: UIViewController?

    init(showFromController: UIViewController, errorMessage: String? = nil) {
        self.showFromController = showFromController
        super.init()

        presentQuestion(errorMessage: errorMessage)
    }

    private func presentQuestion(errorMessage: String?) {
        let alert = UIAlertController(
            title: L10n.diagnosisTitle,
            message: "",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.diagnosisSendAttachment,
                style: .default,
                handler: { [weak self] _ in
                    self?.openMailController(diagnosisInfo: true, errorMessage: errorMessage)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.diagnosisSendWithoutattachment,
                style: .default,
                handler: { [weak self] _ in
                    self?.openMailController(diagnosisInfo: false)
                }
            )
        )
        alert.addAction(UIAlertAction(title: L10n.diagnosisCancel, style: .cancel, handler: nil))
        showFromController?.present(alert, animated: true, completion: nil)
    }

    private func openMailController(diagnosisInfo: Bool, errorMessage: String? = nil) {
        let controller = MFMailComposeViewController()
        controller.setSubject("Zpětná vazba z aplikace eRouška")
        controller.setToRecipients(["info@erouska.cz"])
        controller.mailComposeDelegate = self

        if diagnosisInfo {
            controller.addAttachmentData(
                diagnosisText(errorMessage: errorMessage).data(using: .utf8) ?? Data(),
                mimeType: "text/plain",
                fileName: "diagnosticke_informace.txt"
            )
        }
        showFromController?.present(controller, animated: true, completion: nil)
    }

    private func diagnosisText(errorMessage: String?) -> String {
        let device = Device.current
        let exposureService = AppDelegate.dependency.exposureService
        let connection = try? Reachability().connection

        let formatter = DateFormatter.baseDateTimeFormatter
        let lastKeys = AppSettings.lastProcessedDate.map(formatter.string) ?? "Nikdy"
        let exposureNotification = AppSettings.lastExposureWarningDate.map(formatter.string) ?? "Nikdy"
        let lastExposure = (ExposureList.last?.date).map(formatter.string) ?? "Nikdy"

        let diagnosisText = """
        Verze aplikace: \(App.appVersion) (\(App.bundleBuild))
        Verze systému: iOS \(device.systemVersion ?? UIDevice.current.systemVersion)
        Zařízení: \(Device.identifier)
        Lokalizace: \(Locale.current.identifier)
        Bluetooth: \(exposureService.isBluetoothOn ? "ON" : "OFF")
        Exposure API: \(exposureService.isActive ? "ON" : "OFF")
        Internet: \(connection != .unavailable ? "ON" : "OFF")
        Low power mode: \(device.batteryState?.lowPowerMode == true ? "ON" : "OFF")
        Poslední stažení klíčů: \(lastKeys)
        Poslední notifikace rizikového setkání: \(exposureNotification)
        Poslední rizikové setkání z: \(lastExposure)
        """

        if let error = errorMessage {
            return "Kód chyby: \(error)\n" + diagnosisText
        } else {
            return diagnosisText
        }
    }

}

extension Diagnosis: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
