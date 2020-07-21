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

    private(set) lazy var exposureService: ExposureServicing = ExposureService()

    var deviceToken: Data?

    #if !targetEnvironment(macCatalyst)
    private(set) lazy var functions = Functions.functions(region: AppSettings.firebaseRegion)
    #endif

    lazy var countryCodes: CountryCodesServicing = CountryCodeService()

    lazy var downloader: DownloadServicing = DownloadService()

    func resetAdvertising() {
        guard KeychainService.BUID != nil else { return }
        guard exposureService.status == .active || exposureService.status == .paused else { return }
        exposureService.deactivate { _ in }
    }

}
