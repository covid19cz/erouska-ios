//
//  EFGSPermissionVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 29/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class EFGSPermissionVC: BaseController {

    // MARK: -

    private let viewModel = EFGSPermissionVM()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var enableLabel: UILabel!
    @IBOutlet private weak var enableSwitch: UISwitch!
    @IBOutlet private weak var countriesLabel: UILabel!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var continueButton: RoundedButtonFilled!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
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

    // MARK: - Action

    @IBAction private func continueAction(_ sender: Any) {
        AppSettings.v2_3NewsLaunched = true
        viewModel.setIsPermissionGranted(enableSwitch.isOn)
        perform(segue: StoryboardSegue.Onboarding.privacy)
    }
}

private extension EFGSPermissionVC {

    func setupStrings() {
        title = L10n.efgsPermissionTitle
        navigationItem.backBarButtonItem?.title = L10n.back

        headlineLabel.text = L10n.efgsPermissionHeadline
        bodyLabel.text = L10n.efgsPermissionBody(RemoteValues.efgsDays)
        enableLabel.text = L10n.efgsPermissionSwitch
        countriesLabel.text = RemoteValues.efgsCountries
        continueButton.setTitle(L10n.newsButtonContinue)
    }
}
