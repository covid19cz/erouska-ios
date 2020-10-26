//
//  AppDelegate.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 14/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFunctions
import FirebaseRemoteConfig
import RealmSwift
import RxSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var inBackgroundStage: Bool = false {
        didSet {
            Self.inBackground = inBackgroundStage
        }
    }

    private(set) static var inBackground: Bool = false
    private let bag = DisposeBag()
    private var presentingAnyForceUpdateScreen = false

    // MARK: - Globals

    static var shared: AppDelegate {
        // swiftlint:disable:next force_cast
        UIApplication.shared.delegate as! AppDelegate
    }

    static let dependency = AppDependency()

    var openResultsCallback: CallbackVoid?

    // MARK: - UIApplicationDelegate

    var window: UIWindow?

    func updateInterface() {
        setupInterface()
    }
    // swiftlint:disable:next discouraged_optional_collection
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        log("\n\n\n-START--------------------------------\n")

        clearKeychainIfNeeded()
        generalSetup()
        setupInterface()
        setupBackgroundMode()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        log("\n\n\n-FOREGROUND---------------------------\n")

        inBackgroundStage = false

        updateRemoteValues()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        log("\n\n\n-BACKGROUND---------------------------\n")

        inBackgroundStage = true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        log("\n\n\n-END----------------------------------\n")
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        } else {
            return false
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        #else
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
        #endif
        Self.dependency.deviceToken = deviceToken

        // update token on server
        guard let token = KeychainService.token else { return }
        let data: [String: Any] = [
            "idToken": token,
            "pushRegistrationToken": deviceToken.hexEncodedString()
        ]

        Self.dependency.functions.httpsCallable("changePushToken").call(data) { _, error in
            if let error = error {
                log("AppDelegate: Failed to change push token \(error.localizedDescription)")
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
    }

    // MARK: - Others

    @objc private func didChangeLocale() {
        updateRemoteValues()
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UserNotificationAction.openExposureDetectionResults.rawValue,
             UserNotificationAction.openTestResults.rawValue:
            openResultsCallback?()
        default:
            break
        }
        completionHandler()
    }

}

private extension AppDelegate {

    func generalSetup() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        #if DEBUG && TARGET_IPHONE_SIMULATOR
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        #endif

        FirebaseApp.configure()
        setupDefaultValues()
        updateRemoteValues()

        if AppSettings.lastLegacyDataFetchDate == nil {
            AppSettings.lastLegacyDataFetchDate = AppSettings.currentDataLastFetchDate ?? Date()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didChangeLocale), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }

    func checkFetchedMinSupportedVersion() {
        guard !presentingAnyForceUpdateScreen else { return }

        var viewController: UIViewController
        if RemoteValues.shouldCheckOSVersion, !isDeviceSupported() {
            viewController = StoryboardScene.ForceUpdate.unsupportedDeviceVC.instantiate()
        } else if RemoteValues.shouldCheckOSVersion, Version.currentOSVersion < Version(RemoteValues.serverConfiguration.minSupportedVersion) {
            viewController = StoryboardScene.ForceUpdate.forceOSUpdateVC.instantiate()
        } else if RemoteValues.minSupportedVersion > App.appVersion {
            viewController = StoryboardScene.ForceUpdate.forceUpdateVC.instantiate()
        } else {
            return
        }

        Self.dependency.exposureService.deactivate(callback: nil)

        viewController.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(viewController, animated: true)
    }

    func setupInterface() {
        let window = UIWindow()
        window.backgroundColor = .black
        window.makeKeyAndVisible()
        self.window = window

        let rootViewController: UIViewController?
        var shouldPresentNews = false

        if RemoteValues.shouldCheckOSVersion, !isDeviceSupported() {
            rootViewController = StoryboardScene.ForceUpdate.unsupportedDeviceVC.instantiate()
            presentingAnyForceUpdateScreen = true
        } else if RemoteValues.shouldCheckOSVersion, Version.currentOSVersion < Version(RemoteValues.serverConfiguration.minSupportedVersion) {
            rootViewController = StoryboardScene.ForceUpdate.forceOSUpdateVC.instantiate()
            presentingAnyForceUpdateScreen = true
        } else if RemoteValues.minSupportedVersion > App.appVersion {
            rootViewController = StoryboardScene.ForceUpdate.forceUpdateVC.instantiate()
            presentingAnyForceUpdateScreen = true
        } else if AppSettings.activated, Auth.auth().currentUser != nil {
            rootViewController = StoryboardScene.Active.initialScene.instantiate()

            // refresh token
            Auth.auth().currentUser?.getIDToken(completion: { token, _ in
                if let token = token {
                    KeychainService.token = token
                }
            })
        } else {
            // User with phone number is old user
            if Auth.auth().currentUser?.phoneNumber != nil {
                try? Auth.auth().signOut()
                rootViewController = StoryboardScene.Onboarding.onboardingActivatedUser.instantiate()
                shouldPresentNews = true
            } else {
                rootViewController = StoryboardScene.Onboarding.initialScene.instantiate()
            }
        }

        window.rootViewController = rootViewController

        if shouldPresentNews, !AppSettings.v2_0NewsLaunched {
            AppSettings.v2_0NewsLaunched = true
            let controller = StoryboardScene.News.initialScene.instantiate()
            controller.modalPresentationStyle = .fullScreen
            rootViewController?.present(controller, animated: true)
        }
    }

    func setupBackgroundMode() {
        Self.dependency.background.scheduleBackgroundTaskIfNeeded()
    }

    func clearKeychainIfNeeded() {
        KeychainService.BUID = nil
        KeychainService.TUIDs = []
    }

    func isDeviceSupported() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        let model = UIDevice.current.modelName
        if model.hasPrefix("iPhone") {
            // List of supported devices from https://support.apple.com/cs-cz/guide/iphone/iphe3fa5df43/13.0/ios/13.0
            let modelNumber = String(model[model.index(model.startIndex, offsetBy: 6)...])
            return Double(modelNumber.replacingOccurrences(of: ",", with: ".")) ?? 0 >= 8.0
        }
        return false
        #endif
    }

    func updateRemoteValues() {
        fetchRemoteValues(background: false)
            .subscribe(onSuccess: { [weak self] _ in
                self?.checkFetchedMinSupportedVersion()

                let configuration = RemoteValues.serverConfiguration
                Self.dependency.reporter.updateConfiguration(configuration)
                Self.dependency.verification.updateConfiguration(configuration)
            })
            .disposed(by: bag)
    }
}
