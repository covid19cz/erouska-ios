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

    func fetchRemoteValues(background: Bool) -> Single<Void> {
        #if DEBUG
        let fetchDuration: TimeInterval = 0
        #else
        let fetchDuration: TimeInterval = background ? 1_800 : 3_600
        #endif
        return Single<Void>.create { single in
            RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { _, error in
                if let error = error {
                    log("AppDelegate\(background ? " background" : ""): Got an error fetching remote values \(error)")
                    single(.error(error))
                    return
                }
                RemoteConfig.remoteConfig().activate()
                log("AppDelegate\(background ? " background" : ""): Retrieved values from the Firebase Remote Config!")
                single(.success(()))
            }
            return Disposables.create()
        }
    }

    func remoteConfigValue(forKey key: RemoteConfigValueKey) -> Any {
        return RemoteConfig.remoteConfig()[key.keyValue]
    }

    func remoteConfigInt(forKey key: RemoteConfigValueKey) -> Int {
        return RemoteConfig.remoteConfig()[key.keyValue].numberValue?.intValue ?? 0
    }

    func remoteConfigString(forKey key: RemoteConfigValueKey) -> String {
        return RemoteConfig.remoteConfig()[key.keyValue].stringValue ?? ""
    }
}

enum RemoteConfigValueKey: String, CaseIterable {
    case shareAppDynamicLink

    case helpMarkdown

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

    /// Deprecated
    case verificationServerApiKey

    case appleServerConfiguration
    case appleExposureConfiguration

    var keyValue: String {
        "v2_\(rawValue)"
    }

    var defaultValue: Any {
        switch self {
        case .shareAppDynamicLink:
            return "https://covid19cz.page.link/share"

        case .helpMarkdown:
            return localValue(forResource: "MarkdownBackups", withExtension: "strings", withKey: "helpMarkdownBackup")

        case .minSupportedVersion:
            return Version("2.1.0")
        case .unsupportedDeviceLink:
            return "https://koronavirus.mzcr.cz"
        case .shouldCheckOSVersion:
            return true

        case .exposureBannerTitle:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "encounterWarningDefault")

        case .riskyEncountersTitle:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "riskyEncountersTitleDefault")
        case .riskyEncountersWithSymptoms:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "riskyEncountersWithSymptomsDefault")
        case .riskyEncountersWithoutSymptoms:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "riskyEncountersWithoutSymptomsDefault")

        case .symptomsContentJson:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "symptomsContentJsonDefault")
        case .preventionContentJson:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "preventionContentJsonDefault")
        case .contactsContentJson:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "contactsContentJsonDefault")
        case .exposureHelpContentJson:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "exposureHelpContentJsonDefault")

        case .currentMeasuresUrl:
            return "https://koronavirus.mzcr.cz/aktualni-opatreni/"
        case .conditionsOfUseUrl:
            return "https://erouska.cz/podminky-pouzivani"

        case .noEncounterHeader:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "noEncounterHeaderDefault")
        case .noEncounterBody:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "noEncounterBodyDefault")

        case .exposureUITitle:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "exposureUITitleDefault")
        case .symptomsUITitle:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "symptomsUITitleDefault")
        case .spreadPreventionUITitle:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "spreadPreventionUITitleDefault")
        case .recentExposuresUITitle:
            return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "recentExposuresUITitleDefault")

        case .chatBotLink:
            return "https://erouska.cz/#chat-open"

        case .verificationServerApiKey:
            return ""

        case .appleServerConfiguration:
            #if PROD
            return ServerConfiguration.production
            #else
            return ServerConfiguration.development
            #endif
        case .appleExposureConfiguration:
            return "{\"factorHigh\":0.17,\"factorStandard\":1,\"factorLow\":1.5,\"lowerThreshold\":55,\"higherThreshold\":63,\"triggerThreshold\":15}"
        }
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
        parseRiskyEncountersListContent(from: AppDelegate.shared.remoteConfigString(forKey: .symptomsContentJson), prevention: false)
    }

    static var preventionContent: RiskyEncountersListContent? {
        parseRiskyEncountersListContent(from: AppDelegate.shared.remoteConfigString(forKey: .preventionContentJson), prevention: true)
    }

    static var exposureHelpContent: RiskyEncountersListContent? {
        parseRiskyEncountersListContent(from: AppDelegate.shared.remoteConfigString(forKey: .exposureHelpContentJson), prevention: false)
    }

    private static func parseRiskyEncountersListContent(from rawJson: String, prevention: Bool) -> RiskyEncountersListContent? {
        guard let json = rawJson.data(using: .utf8) else { return nil }
        do {
            let remoteContent = try JSONDecoder().decode(RiskyEncountersListRemoteContent.self, from: json)
            return RiskyEncountersListContent(
                headline: prevention ? nil : remoteContent.title,
                items: remoteContent.items.compactMap {
                    guard let imageUrl = URL(string: $0.iconUrl) else { return nil }
                    return AsyncImageTitleViewModel(imageUrl: imageUrl, title: $0.label)
                },
                footer: prevention ? remoteContent.title : nil
            )
        } catch {
            return nil
        }
    }

    static var contactsContent: [Contact] {
        guard let json = AppDelegate.shared.remoteConfigString(forKey: .contactsContentJson).data(using: .utf8) else { return [] }
        do {
            return try JSONDecoder().decode([ContactContent].self, from: json).compactMap {
                guard let link = URL(string: $0.link) else { return nil }
                return Contact(title: $0.title, text: $0.text, linkTitle: $0.linkTitle, link: link)
            }
        } catch {
            return []
        }
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

    static var verificationServerApiKey: String {
        AppDelegate.shared.remoteConfigString(forKey: .verificationServerApiKey)
    }

    static var serverConfiguration: ServerConfiguration {
        // swiftlint:disable force_cast
        guard let json = AppDelegate.shared.remoteConfigString(forKey: .appleServerConfiguration).data(using: .utf8) else {
            return RemoteConfigValueKey.appleServerConfiguration.defaultValue as! ServerConfiguration
        }
        do {
            return try JSONDecoder().decode(ServerConfiguration.self, from: json)
        } catch {
            return RemoteConfigValueKey.appleServerConfiguration.defaultValue as! ServerConfiguration
        }
        // swiftlint:enable force_cast
    }

    static var exposureConfiguration: ExposureConfiguration {
        guard let json = AppDelegate.shared.remoteConfigString(forKey: .appleExposureConfiguration).data(using: .utf8) else {
            return ExposureConfiguration()
        }
        do {
            return try JSONDecoder().decode(ExposureConfiguration.self, from: json)
        } catch {
            return ExposureConfiguration()
        }
    }

}
