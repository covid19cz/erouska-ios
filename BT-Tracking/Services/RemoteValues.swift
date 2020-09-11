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
        for (key, value) in RemoteValues.defaults {
            guard let object = value as? NSObject else { continue }
            remoteDefaults[key.rawValue] = object
        }

        RemoteConfig.remoteConfig().setDefaults(remoteDefaults)
    }

    func fetchRemoteValues(background: Bool) -> Single<Void> {
        #if DEBUG
        let fetchDuration: TimeInterval = 0
        #else
        let fetchDuration: TimeInterval = background ? 1800 : 3600
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
        return RemoteConfig.remoteConfig()[key.rawValue]
    }

    func remoteConfigInt(forKey key: RemoteConfigValueKey) -> Int {
        return RemoteConfig.remoteConfig()[key.rawValue].numberValue?.intValue ?? 0
    }

    func remoteConfigString(forKey key: RemoteConfigValueKey) -> String {
        return RemoteConfig.remoteConfig()[key.rawValue].stringValue ?? ""
    }
}

enum RemoteConfigValueKey: String {
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

    case currentMeasuresUrl
    case conditionsOfUseUrl

    case noEncounterHeader
    case noEncounterBody

    case exposureUITitle
    case symptomsUITitle
    case spreadPreventionUITitle
    case recentExposuresUITitle

    case chatBotLink

    case verificationServerApiKey
    case appleExposureConfigurationV1
}

struct RemoteValues {

    static let defaults: [RemoteConfigValueKey: Any?] = [
        .shareAppDynamicLink: "https://covid19cz.page.link/share",
        
        .helpMarkdown: helpMarkdownBackup,

        .minSupportedVersion: Version("1.0.0"),
        .unsupportedDeviceLink: "https://koronavirus.mzcr.cz",
        .shouldCheckOSVersion: false,

        .exposureBannerTitle: encounterWarningDefault,

        .riskyEncountersTitle: riskyEncountersTitleDefault,
        .riskyEncountersWithSymptoms: riskyEncountersWithSymptomsDefault,
        .riskyEncountersWithoutSymptoms: riskyEncountersWithoutSymptomsDefault,

        .currentMeasuresUrl: "https://koronavirus.mzcr.cz/aktualni-opatreni/",
        .conditionsOfUseUrl: "https://erouska.cz",

        .noEncounterHeader: noEncounterHeaderDefault,
        .noEncounterBody: noEncounterBodyDefault,

        .exposureUITitle: exposureUITitleDefault,
        .symptomsUITitle: symptomsUITitleDefault,
        .spreadPreventionUITitle: spreadPreventionUITitleDefault,
        .recentExposuresUITitle: recentExposuresUITitleDefault,

        .chatBotLink: "https://erouska.cz/#chat-open",
    ]

    static var shareAppDynamicLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: .shareAppDynamicLink).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Help markdown
    static var helpMarkdown: String {
        return AppDelegate.shared.remoteConfigString(forKey: .helpMarkdown)
    }

    /// Min supported app version. Used for force update.
    static var minSupportedVersion: Version {
        let rawAppVersion = AppDelegate.shared.remoteConfigString(forKey: .minSupportedVersion)
        return Version(rawAppVersion)
    }

    static var unsupportedDeviceLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: .unsupportedDeviceLink)
    }

    static var shouldCheckOSVersion: Bool {
        return AppDelegate.shared.remoteConfigInt(forKey: .shouldCheckOSVersion) == 1
    }

    static var exposureBannerTitle: String {
        return AppDelegate.shared.remoteConfigString(forKey: .exposureBannerTitle)
    }

    static var riskyEncountersTitle: String {
        return AppDelegate.shared.remoteConfigString(forKey: .riskyEncountersTitle)
    }

    static var riskyEncountersWithSymptoms: String {
        return AppDelegate.shared.remoteConfigString(forKey: .riskyEncountersWithSymptoms)
    }

    static var riskyEncountersWithoutSymptoms: String {
        return AppDelegate.shared.remoteConfigString(forKey: .riskyEncountersWithoutSymptoms)
    }

    static var symptomsContent: RiskyEncountersListContent? {
        return parseRiskyEncountersListContent(from: AppDelegate.shared.remoteConfigString(forKey: .symptomsContentJson), prevention: false)
    }

    static var preventionContent: RiskyEncountersListContent? {
        return parseRiskyEncountersListContent(from: AppDelegate.shared.remoteConfigString(forKey: .preventionContentJson), prevention: true)
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
        return AppDelegate.shared.remoteConfigString(forKey: .currentMeasuresUrl)
    }

    static var conditionsOfUseUrl: String {
        return AppDelegate.shared.remoteConfigString(forKey: .conditionsOfUseUrl)
    }

    static var noEncounterHeader: String {
        return AppDelegate.shared.remoteConfigString(forKey: .noEncounterHeader)
    }

    static var noEncounterBody: String {
        return AppDelegate.shared.remoteConfigString(forKey: .noEncounterBody)
    }

    static var exposureUITitle: String {
        return AppDelegate.shared.remoteConfigString(forKey: .exposureUITitle)
    }

    static var symptomsUITitle: String {
        return AppDelegate.shared.remoteConfigString(forKey: .symptomsUITitle)
    }

    static var spreadPreventionUITitle: String {
        return AppDelegate.shared.remoteConfigString(forKey: .spreadPreventionUITitle)
    }

    static var recentExposuresUITitle: String {
        return AppDelegate.shared.remoteConfigString(forKey: .recentExposuresUITitle)
    }

    static var chatBotLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: .chatBotLink)
    }

    static var verificationServerApiKey: String {
        return AppDelegate.shared.remoteConfigString(forKey: .verificationServerApiKey)
    }

    static var exposureConfiguration: ExposureConfiguration {
        guard let json = AppDelegate.shared.remoteConfigString(forKey: .appleExposureConfigurationV1).data(using: .utf8) else {
            return ExposureConfiguration()
        }
        do {
            return try JSONDecoder().decode(ExposureConfiguration.self, from: json)
        } catch {
            return ExposureConfiguration()
        }
    }

}

// MARK: - Backup

private extension RemoteValues {

    static func localValue(forResource resource: String, withExtension extension: String, withKey key: String) -> String {
        guard
            let path = Bundle.main.url(forResource: resource, withExtension: `extension`),
            let dict = NSDictionary(contentsOf: path),
            let value = dict.value(forKey: key) as? String
        else { return "" }

        return value
    }

    static var helpMarkdownBackup: String {
        return localValue(forResource: "MarkdownBackups", withExtension: "strings", withKey: "helpMarkdownBackup")
    }

    static var encounterWarningDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "encounterWarningDefault")
    }

    static var riskyEncountersTitleDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "riskyEncountersTitleDefault")
    }

    static var riskyEncountersWithSymptomsDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "riskyEncountersWithSymptomsDefault")
    }

    static var riskyEncountersWithoutSymptomsDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "riskyEncountersWithoutSymptomsDefault")
    }

    static var noEncounterHeaderDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "noEncounterHeaderDefault")
    }

    static var noEncounterBodyDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "noEncounterBodyDefault")
    }

    static var exposureUITitleDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "exposureUITitleDefault")
    }

    static var symptomsUITitleDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "symptomsUITitleDefault")
    }

    static var spreadPreventionUITitleDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "spreadPreventionUITitleDefault")
    }

    static var recentExposuresUITitleDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "recentExposuresUITitleDefault")
    }
}
