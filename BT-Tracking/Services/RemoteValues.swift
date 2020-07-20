//
//  RemoteValues.swift
//  BT-Tracking
//
//  Created by Stanislav Kasprik on 29/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
#if !targetEnvironment(macCatalyst)
import FirebaseRemoteConfig
#endif
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
    case collectionSeconds
    case waitingSeconds
    case criticalExpositionRssi

    case smsErrorTimeoutSeconds
    case uploadWaitingMinutes
    case persistDataDays

    case faqLink
    case importantLink
    case proclamationLink
    case termsAndConditionsLink
    case aboutLink
    case homepageLink
    case shareAppDynamicLink
    
    case helpMarkdown
    case dataCollectionMarkdown

    case aboutJson
    
    case activeTitleEnabled
    case activeTitleEnabled_en

    case minSupportedVersion
    case unsupportedDeviceLink
    case shouldCheckOSVersion
}

struct RemoteValues {

    static let defaults: [RemoteConfigValueKey: Any?] = [
        .collectionSeconds: 120,
        .waitingSeconds: 0,
        .criticalExpositionRssi: -75,

        .smsErrorTimeoutSeconds: 15 * 60,
        .uploadWaitingMinutes: 15,
        .persistDataDays: 14,

        .faqLink: "https://koronavirus.mzcr.cz/otazky-a-odpovedi/",
        .importantLink: "https://koronavirus.mzcr.cz",
        .proclamationLink: "https://koronavirus.mzcr.cz",
        .termsAndConditionsLink: "https://koronavirus.mzcr.cz",
        .aboutLink: "http://erouska.cz",
        .homepageLink: "http://erouska.cz",
        .shareAppDynamicLink: "https://covid19cz.page.link/share",
        
        .helpMarkdown: helpMarkdownBackup,
        .dataCollectionMarkdown: dataCollectionMarkdownBackup,

        .aboutJson: aboutJsonBackup,
        
        .activeTitleEnabled: activeTitleEnabledDefault,
        .activeTitleEnabled_en: activeTitleEnabledDefaultEn,

        .minSupportedVersion: Version("1.0.0"),
        .unsupportedDeviceLink: "https://koronavirus.mzcr.cz",
        .shouldCheckOSVersion: false,
    ]

    /// doba scanování v sekundách, default = 120
    static var collectionSeconds: Int {
        return AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.collectionSeconds)
    }

    /// doba čekání mezi scany, default = 0
    static var waitingSeconds: Int {
        return AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.waitingSeconds)
    }

    /// pro in-app statistiky, úroveň rssi kdy je kontakt nebezpečný, číslo, default = -75
    static var criticalExpositionRssi: Int {
        return AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.criticalExpositionRssi)
    }

    /// timeout na automatické ověření SMS, default = 20
    static var smsErrorTimeoutSeconds: TimeInterval {
        return TimeInterval(AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.smsErrorTimeoutSeconds))
    }

    /// doba mezi uploady, v minutách, číslo, default = 15min
    static var uploadWaitingMinutes: TimeInterval {
        return TimeInterval(AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.uploadWaitingMinutes) * 60 * 60)
    }
    
    /// počet dní, jak dlouho se mají držet data v telefonu ve dnech, default = 14
    static var persistDataDays: Int {
        return AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.persistDataDays)
    }
    
    static var persistDataInterval: TimeInterval {
        return TimeInterval(persistDataDays * 60 * 60 * 24)
    }
    
    /// odkaz na FAQ - vede z obrazovky Kontakty
    static var faqLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.faqLink)
    }

    /// odkaz na důležité kontakty - vede z obrazovky Kontakty
    static var importantLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.importantLink)
    }

    /// odkaz na prohlášení o podpoře - vede z úvodní obrazovky a z nápovědy
    static var proclamationLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.proclamationLink)
    }

    /// Podminky zpracovan
    static var termsAndConditionsLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.termsAndConditionsLink)
    }

    /// Odkaz na tým - erouska.cz/tym
    static var aboutLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.aboutLink)
    }

    /// Authors json
    static var aboutJson: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.aboutJson)
    }

    /// Homepage - erouska.cz
    static var homepageLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.homepageLink)
    }

    static var shareAppDynamicLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.shareAppDynamicLink).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Help markdown
    static var helpMarkdown: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.helpMarkdown)
    }

    /// Data collection markdown
    static var dataCollectionMarkdown: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.dataCollectionMarkdown)
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
        let rawAppVersion = AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.minSupportedVersion)
        return Version(rawAppVersion)
    }

    static var unsupportedDeviceLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.unsupportedDeviceLink)
    }

    static var shouldCheckOSVersion: Bool {
        return AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.shouldCheckOSVersion) == 1
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
}
