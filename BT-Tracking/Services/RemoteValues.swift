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
    case proclamationLink
    case termsAndConditionsLink
    case aboutLink
    case shareAppDynamicLink
    
    case helpMarkdown
    case dataCollectionMarkdown

    case aboutJson
    
    case activeTitleEnabled
    case activeTitleEnabled_en

    case minSupportedVersion
    case unsupportedDeviceLink
    case shouldCheckOSVersion

    case exposureBannerTitle

    case riskyEncountersTitle
    case riskyEncountersBody

    case symptomsContentJson
    case preventionContentJson
    case contactsContentJson
}

struct RemoteValues {

    static let defaults: [RemoteConfigValueKey: Any?] = [
        .proclamationLink: "https://koronavirus.mzcr.cz",
        .termsAndConditionsLink: "https://koronavirus.mzcr.cz",
        .aboutLink: "http://erouska.cz",
        .shareAppDynamicLink: "https://covid19cz.page.link/share",
        
        .helpMarkdown: helpMarkdownBackup,
        .dataCollectionMarkdown: dataCollectionMarkdownBackup,

        .aboutJson: aboutJsonBackup,
        
        .activeTitleEnabled: activeTitleEnabledDefault,
        .activeTitleEnabled_en: activeTitleEnabledDefaultEn,

        .minSupportedVersion: Version("1.0.0"),
        .unsupportedDeviceLink: "https://koronavirus.mzcr.cz",
        .shouldCheckOSVersion: false,

        .exposureBannerTitle: activeExposureTitleDefault,

        .riskyEncountersTitle: riskyEncountersTitleDefault,
        .riskyEncountersBody: riskyEncountersBodyDefault,
    ]

    /// odkaz na prohlášení o podpoře - vede z úvodní obrazovky a z nápovědy
    static var proclamationLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: .proclamationLink)
    }

    /// Podminky zpracovan
    static var termsAndConditionsLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: .termsAndConditionsLink)
    }

    /// Odkaz na tým - erouska.cz/tym
    static var aboutLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: .aboutLink)
    }

    /// Authors json
    static var aboutJson: String {
        return AppDelegate.shared.remoteConfigString(forKey: .aboutJson)
    }

    static var shareAppDynamicLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: .shareAppDynamicLink).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Help markdown
    static var helpMarkdown: String {
        return AppDelegate.shared.remoteConfigString(forKey: .helpMarkdown)
    }

    /// Data collection markdown
    static var dataCollectionMarkdown: String {
        return AppDelegate.shared.remoteConfigString(forKey: .dataCollectionMarkdown)
    }
    
    /// Main screen title enabled text
    static var activeTitleEnabled: String {

        enum SupportedLanguage: String {
            case cs, en
        }

        var language = SupportedLanguage.cs
        if let preferredLocalization = Bundle.main.preferredLocalizations.first, let preferredLanguage = SupportedLanguage(rawValue: preferredLocalization) {
            language = preferredLanguage
        }

        var key: RemoteConfigValueKey {
            switch language {
            case .en: return .activeTitleEnabled_en
            default: return .activeTitleEnabled
            }
        }

        return AppDelegate.shared.remoteConfigString(forKey: key)
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\", with: "")
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

    static var riskyEncountersBody: String {
        return AppDelegate.shared.remoteConfigString(forKey: .riskyEncountersBody)
    }

    static var symptomsContent: RiskyEncountersListContent? {
        return parseRiskyEncountersListContent(from: AppDelegate.shared.remoteConfigString(forKey: .symptomsContentJson))
    }

    static var preventionContent: RiskyEncountersListContent? {
        return parseRiskyEncountersListContent(from: AppDelegate.shared.remoteConfigString(forKey: .preventionContentJson))
    }

    private static func parseRiskyEncountersListContent(from rawJson: String) -> RiskyEncountersListContent? {
        guard let json = rawJson.data(using: .utf8) else { return nil }
        do {
            let remoteContent = try JSONDecoder().decode(RiskyEncountersListRemoteContent.self, from: json)
            return RiskyEncountersListContent(
                headline: remoteContent.title,
                items: remoteContent.items.compactMap {
                    guard let imageUrl = URL(string: $0.iconUrl) else { return nil }
                    return AsyncImageTitleViewModel(imageUrl: imageUrl, title: $0.label)
                }
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

    static var dataCollectionMarkdownBackup: String {
        return localValue(forResource: "MarkdownBackups", withExtension: "strings", withKey: "dataCollectionInfoBackup")
    }

    static var aboutJsonBackup: String {
        return localValue(forResource: "MarkdownBackups", withExtension: "strings", withKey: "aboutJsonBackup")
    }

    static var activeTitleEnabledDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "activeTitleEnabledDefault")
    }
    
    static var activeTitleEnabledDefaultEn: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "activeTitleEnabledDefaultEn")
    }

    static var activeExposureTitleDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "activeExposureTitleDefault")
    }

    static var riskyEncountersTitleDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "riskyEncountersTitleDefault")
    }

    static var riskyEncountersBodyDefault: String {
        return localValue(forResource: "RemoteTitles", withExtension: "strings", withKey: "riskyEncountersBodyDefault")
    }
}
