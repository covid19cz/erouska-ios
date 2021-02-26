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

final class SendReportsTravelVC: BaseController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasExposureService & HasVerificationService & HasReportService & HasDiagnosis

    var dependencies: Dependencies!

    // MARK: -

    var verificationToken: String? = nil

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

        isModalInPresentation = true
        navigationItem.hidesBackButton = true
        if Device.current.diagonal < 4.1 {
            navigationItem.largeTitleDisplayMode = .never
        }

        buttonsView.connect(with: scrollView)
        buttonsBottomConstraint.constant = ButtonsBackgroundView.BottomMargin

        setupStrings()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch StoryboardSegue.SendReports(segue) {
        case .agreement:
            let controller = segue.destination as? SendReportsShareVC
            controller?.traveler = sender as? Bool ?? false
            controller?.verificationToken = verificationToken
        default:
            break
        }
    }

    // MARK: - Actions

    @IBAction private func confirmAction() {
        log("SendReportsTravelVC: confirmed as traveler")
        perform(segue: StoryboardSegue.SendReports.agreement, sender: true)
    }

    @IBAction private func rejectAction() {
        log("SendReportsTravelVC: rejected as traveler")
        perform(segue: StoryboardSegue.SendReports.agreement, sender: false)
    }

    @IBAction private func closeAction() {
        dismiss(animated: true)
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
