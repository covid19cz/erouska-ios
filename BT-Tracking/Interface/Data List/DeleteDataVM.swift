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

    // MARK: - Localization

    let title = "data_delete_title"
    let body = "data_delete_body"
    let deleteButton = "data_delete_delete_button"
    let deleteSuccess = "data_delete_success"

    // MARK: - Init
    
    init(scannerStore: ScannerStore) {
        self.scannerStore = scannerStore
    }

    // MARK: - Delete data
    
    func deleteAllData() {
        scannerStore.deleteAllData()
        #if !PROD
        FileLogger.shared.purgeLogs()
        #endif
    }
}
