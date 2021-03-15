//
//  RiskyEncountersNegativeVC.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 25/10/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import RxSwift

final class RiskyEncountersNegativeVC: BaseController, HasDependencies {

    // MARK: - Dependencies

    typealias Dependencies = HasRealm

    var dependencies: Dependencies!

    // MARK: -

    @IBOutlet private weak var negativeView: RiskyEncountersNegativeView!

    private var viewModel: RiskyEncountersNegativeVM!
    private let disposeBag = DisposeBag()

    // MARK: -

    override func viewDidLoad() {
        viewModel = RiskyEncountersNegativeVM(dependencies: dependencies)

        super.viewDidLoad()

        title = viewModel.title
        setupCloseButton(#selector(closeAction))
        navigationItem.rightBarButtonItem?.title = L10n.help

        negativeView.setup(
            title: viewModel.negativeTitle,
            body: viewModel.negativeBody,
            previousRiskyEncounters: viewModel.previousRiskyEncountersButton
        )

        viewModel.shouldShowPreviousRiskyEncounters.subscribe(
            onNext: { [weak self] shouldShowPreviousRiskyEncounters in
                guard let self = self else { return }
                self.negativeView.isPreviousRiskyEncountersHidden = !shouldShowPreviousRiskyEncounters
            }
        ).disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? RiskyEncountersListVC else { return }

        switch StoryboardSegue.RiskyEncounters(segue) {
        case .help:
            viewController.viewModel = RiskyEncounterHelpVM()
        default:
            break
        }
    }

    // MARK: - Actions

    @IBAction private func closeAction() {
        dismiss(animated: true)
    }

}
