//
//  AppDependency.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 03/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFunctions

class AppDependency {

    var deviceToken: Data?

    private(set) lazy var functions = Functions.functions(region: AppSettings.firebaseRegion)

    private(set) lazy var exposureService: ExposureServicing = ExposureService()

    private(set) lazy var countryCodes: CountryCodesServicing = CountryCodeService()

    private(set) lazy var reporter: ReportServicing = ReportService(configuration: RemoteValues.serverConfiguration)

    private(set) lazy var verification: VerificationServicing = VerificationService(configuration: RemoteValues.serverConfiguration)

    private(set) lazy var background = BackgroundService(exposureService: exposureService, reporter: reporter)

}
