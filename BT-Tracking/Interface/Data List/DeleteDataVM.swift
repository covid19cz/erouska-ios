//
//  DeleteDataVM.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

final class DeleteDataVM {
    // MARK: - Properties

    private let scannerStore: ScannerStore

    // MARK: - Init

    init(scannerStore: ScannerStore) {
        self.scannerStore = scannerStore
    }

    // MARK: - Alert

    func showAlert() {}

    // MARK: - Delete data

    func deleteAllData() {
        scannerStore.deleteAllData()
        FileLogger.shared.purgeLogs()
    }
}
