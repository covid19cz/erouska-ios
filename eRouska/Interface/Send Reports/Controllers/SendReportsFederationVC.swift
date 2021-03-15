//
//  SendReportsFederationVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 26.02.2021.
//

import UIKit
import DeviceKit

final class SendReportsFederationVC: SendReportingVC {

    // MARK: -
    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyTextView: UITextView!

    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var confirmButton: Button!
    @IBOutlet private weak var rejectButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }

        if Device.current.diagonal < 4.1 {
            navigationItem.largeTitleDisplayMode = .never
        }

        bodyTextView.textContainerInset = .zero
        bodyTextView.textContainer.lineFragmentPadding = 0

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
        log("SendReportsTravelVC: confirmed consentToFederation")
        sendReport?.consentToFederation = true
        AppSettings.sendReport = sendReport

        report()
    }

    @IBAction private func rejectAction() {
        log("SendReportsTravelVC: rejected consentToFederation")
        sendReport?.consentToFederation = false
        AppSettings.sendReport = sendReport

        report()
    }

    @IBAction private func closeAction() {
        dismiss(animated: true)
    }

}

private extension SendReportsFederationVC {

    // MARK: - Setup

    func setupStrings() {
        if Device.current.diagonal < 4.1 {
            titleLabel.isHidden = true
            title = L10n.DataSendShareTitle.part1 + " " + L10n.DataSendShareTitle.part2
        } else {
            title = L10n.DataSendShareTitle.part1
            titleLabel.text = L10n.DataSendShareTitle.part2
        }

        headlineLabel.text = sendReport?.traveler == true ? L10n.DataSendShareHeadline.a : L10n.DataSendShareHeadline.b
        bodyTextView.hyperLink(
            originalText: L10n.dataSendShareBody,
            hyperLink: L10n.dataSendShareBodyLink,
            urlString: RemoteValues.conditionsOfUseUrl
        )
        confirmButton.setTitle(L10n.dataSendShareActionConfirm)
        rejectButton.setTitle(L10n.dataSendShareActionReject)
    }

}
