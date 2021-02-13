//
//  RemoteValues.swift
//  eRouska
//
//  Created by Stanislav Kasprik on 29/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
import RxSwift

extension AppDelegate {

    func setupDefaultValues() {
        var remoteDefaults: [String: NSObject] = [:]
        RemoteConfigValueKey.allCases.forEach {
            remoteDefaults[$0.keyValue] = $0.defaultValue as? NSObject
        }
        RemoteConfig.remoteConfig().setDefaults(remoteDefaults)
    }

    func fetchRemoteValues(background: Bool, ignoreCache: Bool = false) -> Single<Void> {
        #if DEBUG
        var fetchDuration: TimeInterval = 0
        #else
        var fetchDuration: TimeInterval = background ? 1_800 : 3_600
        #endif
        if ignoreCache {
            fetchDuration = 0
        }
        return Single<Void>.create { single in
            RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { _, error in
                if let error = error {
                    log("AppDelegate\(background ? " background" : ""): Got an error fetching remote values \(error)")
                    single(.error(error))
                    return
                }

                RemoteConfig.remoteConfig().activate { _, _ in }

                log("AppDelegate\(background ? " background" : ""): Retrieved values from the Firebase Remote Config!")
                single(.success(()))
            }
            return Disposables.create()
        }
    }

    func remoteConfigBool(forKey key: RemoteConfigValueKey) -> Bool {
        return RemoteConfig.remoteConfig()[key.keyValue].boolValue
    }

    func remoteConfigInt(forKey key: RemoteConfigValueKey) -> Int {
        return RemoteConfig.remoteConfig()[key.keyValue].numberValue.intValue
    }

    func remoteConfigData(forKey key: RemoteConfigValueKey) -> Data {
        return RemoteConfig.remoteConfig()[key.keyValue].dataValue
    }

    func remoteConfigString(forKey key: RemoteConfigValueKey) -> String {
        return RemoteConfig.remoteConfig()[key.keyValue].stringValue ?? ""
    }
}

enum RemoteConfigValueKey: String, CaseIterable {
    case shareAppDynamicLink

    case helpMarkdown
    case helpJson

    case minSupportedVersion
    case unsupportedDeviceLink
    case shouldCheckOSVersion

    case exposureBannerTitle = "encounterWarning"

    case riskyEncountersTitle
    case riskyEncountersWithSymptoms
    case riskyEncountersWithoutSymptoms

    case symptomsContentJson
    case preventionContentJson
    case contactsContentJson
    case exposureHelpContentJson

    case currentMeasuresUrl
    case conditionsOfUseUrl

    case noEncounterHeader
    case noEncounterBody

    case exposureUITitle
    case symptomsUITitle
    case spreadPreventionUITitle
    case recentExposuresUITitle

    case chatBotLink

    case appleIgnoreAndroid
    case appleServerConfiguration
    case appleExposureConfigurationV1 = "appleExposureConfiguration"
    case appleExposureConfigurationV2

    case efgsDays
    case efgsCountries
    case keyExportNonTravellerUrls
    case keyExportEuTravellerUrls

    var keyValue: String {
        "v2_\(rawValue)"
    }

    var defaultValue: Any {
        switch self {
        case .shareAppDynamicLink:
            return defaultLocalValue(withKey: "shareAppDynamicLink")

        case .helpMarkdown:
            return localValue(forResource: "Help", withExtension: "strings", withKey: "helpMarkdown")
        case .helpJson:
            return localValue(forResource: "MarkdownBackups", withExtension: "strings", withKey: "helpJsonBackup")

        case .minSupportedVersion:
            return Version("2.1.0")
        case .unsupportedDeviceLink:
            return defaultLocalValue(withKey: "unsupportedDeviceLink")
        case .shouldCheckOSVersion:
            return true

        case .exposureBannerTitle:
            return defaultLocalValue(withKey: "encounterWarning")

        case .riskyEncountersTitle:
            return defaultLocalValue(withKey: "riskyEncountersTitle")
        case .riskyEncountersWithSymptoms:
            return defaultLocalValue(withKey: "riskyEncountersWithSymptoms")
        case .riskyEncountersWithoutSymptoms:
            return defaultLocalValue(withKey: "riskyEncountersWithoutSymptoms")

        case .symptomsContentJson:
            return defaultLocalValue(withKey: "symptomsContentJson")
        case .preventionContentJson:
            return defaultLocalValue(withKey: "preventionContentJson")
        case .contactsContentJson:
            return defaultLocalValue(withKey: "contactsContentJson")
        case .exposureHelpContentJson:
            return defaultLocalValue(withKey: "exposureHelpContentJson")

        case .currentMeasuresUrl:
            return defaultLocalValue(withKey: "currentMeasuresUrl")
        case .conditionsOfUseUrl:
            return defaultLocalValue(withKey: "conditionsOfUseUrl")

        case .noEncounterHeader:
            return defaultLocalValue(withKey: "noEncounterHeader")
        case .noEncounterBody:
            return defaultLocalValue(withKey: "noEncounterBody")

        case .exposureUITitle:
            return defaultLocalValue(withKey: "exposureUITitle")
        case .symptomsUITitle:
            return defaultLocalValue(withKey: "symptomsUITitle")
        case .spreadPreventionUITitle:
            return defaultLocalValue(withKey: "spreadPreventionUITitle")
        case .recentExposuresUITitle:
            return defaultLocalValue(withKey: "recentExposuresUITitle")

        case .chatBotLink:
            return defaultLocalValue(withKey: "chatBotLink")

        case .appleServerConfiguration:
            #if PROD
            return ServerConfiguration.production
            #else
            return ServerConfiguration.development
            #endif
        case .appleExposureConfigurationV1:
            return defaultLocalValue(withKey: "appleExposureConfiguration")
        case .appleIgnoreAndroid:
            return true
        case .appleExposureConfigurationV2:
            return """
                {
                \"immediateDurationWeight\":100,
                \"nearDurationWeight\":100,
                \"mediumDurationWeight\":100,
                \"otherDurationWeight\":100,
                \"infectiousnessForDaysSinceOnsetOfSymptoms\":{
                \"unknown\":1,
                \"-14\":1,
                \"-13\":1,
                \"-12\":1,
                \"-11\":1,
                \"-10\":1,
                \"-9\":1,
                \"-8\":1,
                \"-7\":1,
                \"-6\":1,
                \"-5\":1,
                \"-4\":1,
                \"-3\":1,
                \"-2\":1,
                \"-1\":1,
                \"0\":1,
                \"1\":1,
                \"2\":1,
                \"3\":1,
                \"4\":1,
                \"5\":1,
                \"6\":1,
                \"7\":1,
                \"8\":1,
                \"9\":1,
                \"10\":1,
                \"11\":1,
                \"12\":1,
                \"13\":1,
                \"14\":1
                },
                \"infectiousnessStandardWeight\":100,
                \"infectiousnessHighWeight\":100,
                \"reportTypeConfirmedTestWeight\":100,
                \"reportTypeConfirmedClinicalDiagnosisWeight\":100,
                \"reportTypeSelfReportedWeight\":100,
                \"reportTypeRecursiveWeight\":100,
                \"reportTypeNoneMap\":1,
                \"minimumRiskScore\":0,
                \"attenuationDurationThresholds\":[50, 70],
                \"attenuationLevelValues\":[1, 2, 3, 4, 5, 6, 7, 8],
                \"daysSinceLastExposureLevelValues\":[1, 2, 3, 4, 5, 6, 7, 8],
                \"durationLevelValues\":[1, 2, 3, 4, 5, 6, 7, 8],
                \"transmissionRiskLevelValues\":[1, 2, 3, 4, 5, 6, 7, 8]
                }
            """

        case .efgsDays:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "efgsDaysDefault")
        case .efgsCountries:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "efgsCountriesDefault")

        case .keyExportNonTravellerUrls, .keyExportEuTravellerUrls:
            return "{}"
        }
    }

    private func defaultLocalValue(withKey key: String) -> String {
        return localValue(forResource: "RemoteConfig", withExtension: "strings", withKey: key)
    }

    private func localValue(forResource resource: String, withExtension extension: String, withKey key: String) -> String {
        guard
            let path = Bundle.main.url(forResource: resource, withExtension: `extension`),
            let dict = NSDictionary(contentsOf: path),
            let value = dict.value(forKey: key) as? String
            else {
                print("Didn't found value for \(key)")
                return ""
        }
        return value
    }

}

struct RemoteValues {

    static var shareAppDynamicLink: String {
        AppDelegate.shared.remoteConfigString(forKey: .shareAppDynamicLink).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Help markdown
    static var helpMarkdown: String {
        AppDelegate.shared.remoteConfigString(forKey: .helpMarkdown)
    }

    /// Help in json and markdown
    static var helpJson: Data {
        AppDelegate.shared.remoteConfigData(forKey: .helpJson)
    }

    /// Min supported app version. Used for force update.
    static var minSupportedVersion: Version {
        let rawAppVersion = AppDelegate.shared.remoteConfigString(forKey: .minSupportedVersion)
        return Version(rawAppVersion)
    }

    static var unsupportedDeviceLink: String {
        AppDelegate.shared.remoteConfigString(forKey: .unsupportedDeviceLink)
    }

    static var shouldCheckOSVersion: Bool {
        AppDelegate.shared.remoteConfigInt(forKey: .shouldCheckOSVersion) == 1
    }

    static var exposureBannerTitle: String {
        AppDelegate.shared.remoteConfigString(forKey: .exposureBannerTitle)
    }

    static var riskyEncountersTitle: String {
        AppDelegate.shared.remoteConfigString(forKey: .riskyEncountersTitle)
    }

    static var riskyEncountersWithSymptoms: String {
        AppDelegate.shared.remoteConfigString(forKey: .riskyEncountersWithSymptoms)
    }

    static var riskyEncountersWithoutSymptoms: String {
        AppDelegate.shared.remoteConfigString(forKey: .riskyEncountersWithoutSymptoms)
    }

    static var symptomsContent: RiskyEncountersListContent? {
        parseRiskyEncountersListContent(from: .symptomsContentJson, prevention: false)
    }

    static var preventionContent: RiskyEncountersListContent? {
        parseRiskyEncountersListContent(from: .preventionContentJson, prevention: true)
    }

    static var exposureHelpContent: RiskyEncountersListContent? {
        parseRiskyEncountersListContent(from: .exposureHelpContentJson, prevention: false)
    }

    private static func parseRiskyEncountersListContent(from key: RemoteConfigValueKey, prevention: Bool) -> RiskyEncountersListContent? {
        guard let remoteContent = try? decodeValue(RiskyEncountersListRemoteContent.self, at: key) else { return nil }
        return RiskyEncountersListContent(
            headline: prevention ? nil : remoteContent.title,
            items: remoteContent.items.compactMap {
                guard let imageUrl = URL(string: $0.iconUrl) else { return nil }
                return AsyncImageTitleViewModel(imageUrl: imageUrl, title: $0.label)
            },
            footer: prevention ? remoteContent.title : nil
        )
    }

    static var contactsContent: [Contact] {
        (try? decodeValue([ContactContent].self, at: .contactsContentJson))?.compactMap {
            guard let link = URL(string: $0.link) else { return nil }
            return Contact(title: $0.title, text: $0.text, linkTitle: $0.linkTitle, link: link)
        } ?? []
    }

    static var currentMeasuresUrl: String {
        AppDelegate.shared.remoteConfigString(forKey: .currentMeasuresUrl)
    }

    static var conditionsOfUseUrl: String {
        AppDelegate.shared.remoteConfigString(forKey: .conditionsOfUseUrl)
    }

    static var noEncounterHeader: String {
        AppDelegate.shared.remoteConfigString(forKey: .noEncounterHeader)
    }

    static var noEncounterBody: String {
        AppDelegate.shared.remoteConfigString(forKey: .noEncounterBody)
    }

    static var exposureUITitle: String {
        AppDelegate.shared.remoteConfigString(forKey: .exposureUITitle)
    }

    static var symptomsUITitle: String {
        AppDelegate.shared.remoteConfigString(forKey: .symptomsUITitle)
    }

    static var spreadPreventionUITitle: String {
        AppDelegate.shared.remoteConfigString(forKey: .spreadPreventionUITitle)
    }

    static var recentExposuresUITitle: String {
        AppDelegate.shared.remoteConfigString(forKey: .recentExposuresUITitle)
    }

    static var chatBotLink: String {
        AppDelegate.shared.remoteConfigString(forKey: .chatBotLink)
    }

    static var serverConfiguration: ServerConfiguration {
        // swiftlint:disable force_cast
        (try? decodeValue(ServerConfiguration.self, at: .appleServerConfiguration))
            ?? RemoteConfigValueKey.appleServerConfiguration.defaultValue as! ServerConfiguration
        // swiftlint:enable force_cast
    }

    static var exposureConfiguration: ExposureConfiguration {
        func defaults() -> ExposureConfiguration {
            if #available(iOS 13.7, *) {
                return ExposureConfigurationV2()
            } else {
                return ExposureConfigurationV1()
            }
        }

        if #available(iOS 13.7, *) {
            guard let json = AppDelegate.shared.remoteConfigString(forKey: .appleExposureConfigurationV2).data(using: .utf8) else {
                return defaults()
            }
            do {
                return try JSONDecoder().decode(ExposureConfigurationV2.self, from: json)
            } catch {
                return defaults()
            }
        } else {
            guard let json = AppDelegate.shared.remoteConfigString(forKey: .appleExposureConfigurationV1).data(using: .utf8) else {
                return defaults()
            }
            do {
                return try JSONDecoder().decode(ExposureConfigurationV1.self, from: json)
            } catch {
                return defaults()
            }
        }
    }

    static var keyExportNonTravellerUrls: [ReportIndex] {
        (try? decodeValue([ReportIndex].self, at: .keyExportNonTravellerUrls)) ?? []
    }

    static var keyExportEuTravellerUrls: [ReportIndex] {
        (try? decodeValue([ReportIndex].self, at: .keyExportEuTravellerUrls)) ?? []
    }

    private static func decodeValue<T>(_ type: T.Type, at key: RemoteConfigValueKey) throws -> T? where T: Decodable {
        guard let jsonData = AppDelegate.shared.remoteConfigString(forKey: key).data(using: .utf8) else {
            return key.defaultValue as? T
        }
        return try JSONDecoder().decode(T.self, from: jsonData)
    }

    static var efgsDays: String {
        AppDelegate.shared.remoteConfigString(forKey: .efgsDays)
    }

    static var efgsCountries: String {
        AppDelegate.shared.remoteConfigString(forKey: .efgsCountries)
    }

    static var appleIgnoreAndroid: Bool {
        AppDelegate.shared.remoteConfigBool(forKey: .appleIgnoreAndroid)
    }

}
