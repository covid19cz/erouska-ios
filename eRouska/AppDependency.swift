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

protocol HasDependencies: CanInjectDependencies {
    associatedtype Dependencies

    var dependencies: Dependencies! { get set }
}

protocol CanInjectDependencies: class {
    func injectDependencies()
}

extension HasDependencies {
    func injectDependencies() {
        self.dependencies = AppDependency.shared as? Dependencies
    }
}

final class AppDependency {

    static let shared = AppDependency()

    private(set) lazy var functions = Functions.functions(region: AppSettings.firebaseRegion)

    private(set) lazy var exposure: ExposureServicing = ExposureService()

    private(set) lazy var exposureList: ExposureListing = ExposureList(dependencies: self)

    private(set) lazy var reporter: ReportServicing = ReportService(configuration: RemoteValues.serverConfiguration)

    private(set) lazy var verification: VerificationServicing = VerificationService(configuration: RemoteValues.serverConfiguration)

    private(set) lazy var background: BackgroundServicing = BackgroundService(dependencies: self)

    private(set) lazy var help: HelpServicing = HelpService()

    private(set) lazy var diagnosis: Diagnosis = DiagnosisService(dependencies: self)

    var deviceToken: Data?

    let realm: Realm = {
        var oldV1Data: [String: ExposureDataV1] = [:]

        let configuration = Realm.Configuration(
            schemaVersion: 13,
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

        // swiftlint:disable:next force_try
        let realm = try! Realm()

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
    }()
}

extension AppDependency: HasExposureService { }
extension AppDependency: HasExposureList { }
extension AppDependency: HasReportService { }
extension AppDependency: HasVerificationService { }
extension AppDependency: HasBackgroundService { }
extension AppDependency: HasHelpService { }
extension AppDependency: HasFunctions { }
extension AppDependency: HasRealm { }
extension AppDependency: HasDiagnosis { }
extension AppDependency: HasOther { }
