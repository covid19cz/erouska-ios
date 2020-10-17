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
import RealmSwift

final class AppDependency {

    var deviceToken: Data?

    private(set) lazy var functions = Functions.functions(region: AppSettings.firebaseRegion)

    private(set) lazy var exposureService: ExposureServicing = ExposureService()

    private(set) lazy var countryCodes: CountryCodesServicing = CountryCodeService()

    private(set) lazy var reporter: ReportServicing = ReportService(configuration: RemoteValues.serverConfiguration)

    private(set) lazy var verification: VerificationServicing = VerificationService(configuration: RemoteValues.serverConfiguration)

    private(set) lazy var background = BackgroundService(exposureService: exposureService, reporter: reporter)

    var realm: Realm {
        let configuration = Realm.Configuration(
            schemaVersion: 2,

            migrationBlock: { _, oldSchemaVersion in
                if oldSchemaVersion < 3 {

                }
            }
        )

        Realm.Configuration.defaultConfiguration = configuration

        // swiftlint:disable force_try
        return try! Realm()
        // swiftlint:enable force_try
    }
}
