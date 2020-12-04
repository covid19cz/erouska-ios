//
//  EFGSSettingsVC.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 21.11.2020.
//

import UIKit

final class EFGSSettingsVC: UIViewController {

    // MARK: -

    private let viewModel = EFGSSettingsVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var enableLabel: UILabel!
    @IBOutlet private weak var enableSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        enableSwitch.isOn = AppSettings.efgsEnabled
        setupStrings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupLargeTitleAutoAdjustFont()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupLargeTitleAutoAdjustFont()
    }

    @IBAction private func changeSettings() {
        if AppSettings.efgsEnabled {
            showAlert(
                title: L10n.efgsSettingsAlertTitle(RemoteValues.efgsDays),
                message: nil,
                okTitle: L10n.efgsSettingsAlertEnable,
                okHandler: { [weak self] in
                    self?.enableSwitch.setOn(true, animated: true)
                },
                action: (L10n.efgsSettingsAlertDisable, {
                    AppSettings.efgsEnabled = false
                })
            )
        } else {
            AppSettings.efgsEnabled = true
        }
    }

}

private extension EFGSSettingsVC {

    func setupStrings() {
        title = L10n.efgsSettingsTitle
        navigationItem.backBarButtonItem?.title = L10n.back

        headlineLabel.text = L10n.efgsSettingsHeadline
        bodyLabel.text = L10n.efgsSettingsBody(RemoteValues.efgsDays)
        enableLabel.text = L10n.efgsSettingsSwitch
    }

}
