//
//  DeleteDataVC.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

final class DeleteDataVC: UIViewController {

    private let viewModel = DeleteDataVM(scannerStore: AppDelegate.shared.scannerStore)

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        title = "Smazat data"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Action
    
    @IBAction private func deleteAllData(_ sender: Any) {
        viewModel.deleteAllData()

        let controller = (tabBarController?.viewControllers?.first as? UINavigationController)?.topViewController as? ActiveAppController
        controller?.pauseScanning()

        showError(title: "Všechna data jsme odstranili a eRoušku pozastavili", message: "", okHandler: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
    }
}
