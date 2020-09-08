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
        return UIApplication.shared.delegate as! AppDelegate
    }

    static var dependency = AppDependency()
    
    // MARK: - UIApplicationDelegate

    var window: UIWindow? = nil

    func updateInterface() {
        setupInterface()
    }

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

        fetchRemoteValues(background: false)
            .subscribe(onSuccess: { [weak self] _ in
                self?.checkFetchedMinSupportedVersion()
            })
            .disposed(by: bag)
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        log("\n\n\n-BACKGROUND---------------------------\n")

        inBackgroundStage = true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        log("\n\n\n-END----------------------------------\n")
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        } else {
            return false
        }
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        #else
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
        #endif
        Self.dependency.deviceToken = deviceToken

        // update token on server
        guard let token = KeychainService.token else { return } // TODO: Should be eHRID?
        let data: [String: Any] = [
            "idToken": token,
            "pushRegistrationToken": deviceToken.hexEncodedString()
        ]

        Self.dependency.functions.httpsCallable("changePushToken").call(data) { result, error in
            if let error = error {
                log("AppDelegate: Failed to change push token \(error.localizedDescription)")
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
    }

}

private extension AppDelegate {

    func generalSetup() {
        let generalCategory = UNNotificationCategory(
            identifier: "Scanning",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([generalCategory])

        #if DEBUG && TARGET_IPHONE_SIMULATOR
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        #endif

        FirebaseApp.configure()
        setupDefaultValues()

        let configuration = Realm.Configuration(
            schemaVersion: 4,
            migrationBlock: { migration, oldSchemaVersion in

            }
        )

        Realm.Configuration.defaultConfiguration = configuration
    }

    func checkFetchedMinSupportedVersion() {
        guard !presentingAnyForceUpdateScreen else { return }

        var viewControllerIdentifier: String?
        if RemoteValues.shouldCheckOSVersion, !isDeviceSupported() {
            viewControllerIdentifier = "UnsupportedDeviceVC"
        } else if RemoteValues.shouldCheckOSVersion, Version.currentOSVersion < Version(Self.dependency.configuration.minSupportedVersion) {
            viewControllerIdentifier = "ForceOSUpdateVC"
        } else if RemoteValues.minSupportedVersion > App.appVersion {
            viewControllerIdentifier = "ForceUpdateVC"
        }

        guard let identifier = viewControllerIdentifier else { return }

        Self.dependency.exposureService.deactivate(callback: nil)

        let viewController = UIStoryboard(name: "ForceUpdate", bundle: nil).instantiateViewController(withIdentifier: identifier)
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
            rootViewController = UIStoryboard(name: "ForceUpdate", bundle: nil).instantiateViewController(withIdentifier: "UnsupportedDeviceVC")
            presentingAnyForceUpdateScreen = true
        } else if RemoteValues.shouldCheckOSVersion, Version.currentOSVersion < Version(Self.dependency.configuration.minSupportedVersion) {
            rootViewController = UIStoryboard(name: "ForceUpdate", bundle: nil).instantiateViewController(withIdentifier: "ForceOSUpdateVC")
            presentingAnyForceUpdateScreen = true
        } else if RemoteValues.minSupportedVersion > App.appVersion {
            rootViewController = UIStoryboard(name: "ForceUpdate", bundle: nil).instantiateViewController(withIdentifier: "ForceUpdateVC")
            presentingAnyForceUpdateScreen = true
        } else if AppSettings.activated, Auth.auth().currentUser != nil {
            rootViewController = UIStoryboard(name: "Active", bundle: nil).instantiateInitialViewController()

            // refresh token
            Auth.auth().currentUser?.getIDToken(completion: { token, error in
                if let token = token {
                    KeychainService.token = token
                }
            })
        } else {
            // User with phone number is old user
            if Auth.auth().currentUser != nil {
                try? Auth.auth().signOut()
                rootViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "OnboardingActivatedUser")
                shouldPresentNews = true
            } else {
                rootViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController()
            }
        }

        window.rootViewController = rootViewController

        if shouldPresentNews, !AppSettings.v2_0NewsLaunched {
            AppSettings.v2_0NewsLaunched = true
            guard let controller = UIStoryboard(name: "News", bundle: nil).instantiateInitialViewController() else { return }
            controller.modalPresentationStyle = .fullScreen
            rootViewController?.present(controller, animated: true)
        }
    }

    func setupBackgroundMode() {
        Self.dependency.background.scheduleBackgroundTaskIfNeeded()
    }

    func clearKeychainIfNeeded() {
        KeychainService.BUID = nil
        KeychainService.TUIDs = nil
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
}
