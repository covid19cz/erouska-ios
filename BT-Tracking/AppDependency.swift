//
//  AppDependency.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 03/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
#if !targetEnvironment(macCatalyst)
import Firebase
import FirebaseFunctions
#endif

class AppDependency {

    private(set) lazy var advertiser: BTAdvertising = BTFakeAdvertiser(
        TUIDs: KeychainService.TUIDs ?? [],
        IDRotation: AppSettings.TUIDRotation
    )
    private(set) lazy var scanner: BTScannering = BTFakeScanner()
    lazy var scannerStore: ScannerStore = {
        let store = ScannerStore(
            scanningPeriod: RemoteValues.collectionSeconds,
            dataPurgeInterval: RemoteValues.persistDataInterval
        )
        scanner.add(delegate: store)
        return store
    }()
    var deviceToken: Data?

    #if !targetEnvironment(macCatalyst)
    private(set) lazy var functions = Functions.functions(region: AppSettings.firebaseRegion)
    #endif

    func resetAdvertising() {
        guard KeychainService.BUID != nil else { return }
        let wasRunning = advertiser.isRunning
        advertiser.stop()
        advertiser = BTFakeAdvertiser(
            TUIDs: KeychainService.TUIDs ?? [],
            IDRotation: AppSettings.TUIDRotation
        )

        if wasRunning {
            advertiser.start()
        }
    }

}
