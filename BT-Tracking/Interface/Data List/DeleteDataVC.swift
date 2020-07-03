//
//  DeleteDataVC.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class DeleteDataVC: UIViewController {

    // MARK: -

    private let viewModel = DeleteDataVM(scannerStore: AppDelegate.dependency.scannerStore)

    // MARK: - Outlets

    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var deleteButton: RoundedButtonFilled!


    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        navigationItem.localizedTitle(viewModel.title)

        bodyLabel.localizedText(viewModel.body)
        deleteButton.localizedTitle(viewModel.deleteButton)
    }
    
    // MARK: - Action
    
    @IBAction private func deleteAllData(_ sender: Any) {
        viewModel.deleteAllData()

        let controller = (tabBarController?.viewControllers?.first as? UINavigationController)?.topViewController as? ActiveAppVC
        controller?.pauseScanning()

        showAlert(
            title: viewModel.deleteSuccess,
            okHandler: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
    }
}
