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
import UserNotifications

final class Diagnosis: NSObject {

    struct ErrorReport {
        let code: String
        let message: String
    }

    enum Kind {
        case error(ErrorReport?)
        case errorWithDiagnosis(ErrorReport?)
        case noCode
    }

    enum ScreenName: String {
        case exposurePermission = "A2"

        case sendCode = "O1"
        case sendCodeResult = "O4"
        case sendNoCode = "O6"

        case contact = "K1"

        case help = "N1"
        case howItWorks = "N3"
    }

    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

    private weak var showFromController: UIViewController?

    private var screenName: ScreenName
    private var kind: Kind

    init(showFromController: UIViewController, screenName: ScreenName, kind: Kind) {
        self.showFromController = showFromController
        self.screenName = screenName
        self.kind = kind
        super.init()

        switch kind {
        case .error(let error):
            presentQuestion(error)
        case .errorWithDiagnosis:
            openMailController(diagnosisInfo: true)
        default:
            openMailController(diagnosisInfo: false)
        }
    }

    private func presentQuestion(_ error: ErrorReport?) {
        let alert = UIAlertController(
            title: error == nil ? L10n.diagnosisTitleBase : L10n.diagnosisTitleError,
            message: "",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.diagnosisSendAttachment,
                style: .default,
                handler: { [weak self] _ in
                    self?.openMailController(diagnosisInfo: true)
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

    private func openMailController(diagnosisInfo: Bool) {
        let controller = MFMailComposeViewController()
        controller.setToRecipients(["info@erouska.cz"])
        controller.mailComposeDelegate = self

        let error: ErrorReport?
        switch kind {
        case .error(let object), .errorWithDiagnosis(let object):
            error = object
        case .noCode:
            controller.setSubject("Nepřišla mi SMS s ověřovacím kódem")
            controller.setMessageBody(noCodeText(), isHTML: false)
            error = nil
        }

        if diagnosisInfo {
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
                DispatchQueue.main.async {
                    controller.addAttachmentData(
                        self.diagnosisText(error: error, notitificationSettings: settings).data(using: .utf8) ?? Data(),
                        mimeType: "text/plain",
                        fileName: "diagnosticke_informace.txt"
                    )
                    self.showFromController?.present(controller, animated: true, completion: nil)
                }
            })
        } else {
            showFromController?.present(controller, animated: true, completion: nil)
        }
    }

    private func noCodeText() -> String {
        return """
        Milý týme eRoušky,
        mám pozitivní test na COVID-19 a nepřišla mi SMS s ověřovacím kódem pro eRoušku.
        Celé jméno uvedené na žádance o test:
        Telefonní číslo uvedené na žádance o test:
        Datum výsledku testů:
        Odběrové místo / laboratoř, ze které mi přišly výsledky testu:
        Typ testu (PCR/antigen):
        """
    }

    private func diagnosisText(error: ErrorReport?, notitificationSettings: UNNotificationSettings) -> String {
        let device = Device.current
        let exposureService = AppDelegate.dependency.exposure
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
        Notifikace: \(notitificationSettings.authorizationStatus == .authorized) ? "ON" : "OFF")
        Aktualizace na pozadí: \(UIApplication.shared.backgroundRefreshStatus == .available ? "ON" : "OFF")
        Internet: \(connection != .unavailable ? "ON" : "OFF")
        Low power mode: \(device.batteryState?.lowPowerMode == true ? "ON" : "OFF")
        Poslední stažení klíčů: \(lastKeys)
        Poslední notifikace rizikového setkání: \(exposureNotification)
        Poslední rizikové setkání z: \(lastExposure)
        Obrazovka: \(screenName)
        """

        if let error = error {
            return "Kód chyby: \(error.code)\n" + "Detail chyby: \(error.message)\n" + diagnosisText
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
