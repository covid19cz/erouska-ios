//
//  EFGSPermissionVC.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 29/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift

final class EFGSPermissionVC: UIViewController {

    // MARK: -

    private let viewModel = EFGSPermissionVM()
    private let disposeBag = DisposeBag()

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var enableLabel: UILabel!
    @IBOutlet private weak var enableSwitch: UISwitch!
    @IBOutlet private weak var buttonsView: ButtonsBackgroundView!
    @IBOutlet private weak var continueButton: RoundedButtonFilled!

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonsView.connect(with: scrollView)
        setupStrings()

        enableSwitch.rx
            .controlEvent(.valueChanged)
            .withLatestFrom(enableSwitch.rx.value)
            .subscribe { [viewModel] in viewModel.efgsPermissionGranted = $0 }
            .disposed(by: disposeBag)
    }

    // MARK: - Action

    @IBAction private func continueAction(_ sender: Any) {
        perform(segue: StoryboardSegue.Onboarding.privacy)
    }
}

private extension EFGSPermissionVC {

    func setupStrings() {
        title = "Spolupráce se zahraničím"
        navigationItem.backBarButtonItem?.title = L10n.back

        headlineLabel.text = "Pomozte v boji s COVID-19 i při cestách do zahraničí"
        bodyLabel.text = """
        COVID-19 nezná hranice a díky spolupráci mezi zeměmi Evropské unie vás eRouška může informovat o možném riziku nákazy.
        Povolte si prosím Spolupráci se zahraničím, pokud jste byli v posledních 14 dnech v některé ze zemí Evropské unie nebo do nich jezdíte pravidelně. eRouška vás upozorní na možnost setkání s nakaženým nemocí COVID-19.
        Nastavení můžete kdykoliv změnit v aplikaci.
        Aktuálně s eRouškou spolupracuje Dánsko, Litva, Lotyšsko, Německo a Rakousko.
        """
        enableLabel.text = "TODO"
        continueButton.setTitle("Pokračovat")
    }
}
