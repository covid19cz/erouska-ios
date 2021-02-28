//
//  SendReportsTravelVC.swift
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

final class SendReportsTravelVC: BaseController, SendReporting {

    // MARK: -

    var sendReport: SendReport?

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var enableLabel: UILabel!
    @IBOutlet private weak var enableSwitch: UISwitch!
    @IBOutlet private weak var datePicker: UIDatePicker!

    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var confirmButton: Button!
    @IBOutlet private weak var rejectButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()

        isModalInPresentation = true
        if Device.current.diagonal < 4.1 {
            navigationItem.largeTitleDisplayMode = .never
        }

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin

        setupStrings()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        let controller = segue.destination as? SendReporting
        controller?.sendReport = sendReport
    }

    // MARK: - Actions

    @IBAction private func confirmAction() {
        log("SendReportsTravelVC: confirmed as traveler")

        sendReport?.traveler = true
        perform(segue: StoryboardSegue.SendReports.agreement)
    }

    @IBAction private func rejectAction() {
        log("SendReportsTravelVC: rejected as traveler")

        sendReport?.traveler = true
        perform(segue: StoryboardSegue.SendReports.agreement)
    }

}

private extension SendReportsTravelVC {

    // MARK: - Setup

    func setupStrings() {
        title = L10n.dataSendTravelTitle

        headlineLabel.text = L10n.dataSendTravelHeadline
        bodyLabel.text = L10n.dataSendTravelBody
        confirmButton.setTitle(L10n.dataSendTravelActionConfirm)
        rejectButton.setTitle(L10n.dataSendTravelActionReject)
    }

}