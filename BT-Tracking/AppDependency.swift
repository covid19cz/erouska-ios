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
        var oldV1Data: [String: ExposureDataV1] = [:]

        let configuration = Realm.Configuration(
            schemaVersion: 5,

            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 5 {
                    migration.enumerateObjects(ofType: ExposureRealm.className()) { oldObject, newObject in
                        newObject?["detectedDate"] = Date(timeIntervalSince1970: 0)

                        let data = ExposureDataV1()
                        data.duration = oldObject?["duration"] as? Double ?? 0
                        data.totalRiskScore = oldObject?["totalRiskScore"] as? Int ?? 0
                        data.transmissionRiskLevel = oldObject?["transmissionRiskLevel"] as? Int ?? 0
                        data.attenuationValue = oldObject?["attenuationValue"] as? Int ?? 0

                        oldV1Data[oldObject?["id"] as? String ?? ""] = data
                    }
                }
            }
        )

        Realm.Configuration.defaultConfiguration = configuration

        // swiftlint:disable force_try
        let realm = try! Realm()
        // swiftlint:enable force_try

        if !oldV1Data.values.isEmpty {
            let exposures = realm.objects(ExposureRealm.self)
            try? realm.write {
                for (key, value) in oldV1Data {
                    let exposure = exposures.first(where: { $0.id == key })
                    value.attenuationDurations = exposure?.attenuationDurations ?? value.attenuationDurations
                    exposure?.attenuationDurations = .init()
                    exposure?.dataV1 = value
                }
            }
        }

        return realm
    }
}
