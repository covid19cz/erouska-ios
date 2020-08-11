//
//  AppDelegate.swift
// eRouska
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
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let backgroundTaskIdentifier = Bundle.main.bundleIdentifier! + ".exposure-notification"
    private var inBackgroundStage: Bool = false {
        didSet {
            Self.inBackground = inBackgroundStage
        }
    }

    private(set) static var inBackground: Bool = false
    private let bag = DisposeBag()
    private var backgroundFetch: UIBackgroundTaskIdentifier?
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
        guard let buid = KeychainService.BUID else { return } // TODO: Should be eHRID?
        let data: [String: Any] = [
            "buid": buid,
            "pushRegistrationToken": deviceToken.hexEncodedString()
        ]

        Self.dependency.functions.httpsCallable("changePushToken").call(data) { result, error in
            if let error = error {
                log("AppDelegate: Failed to change push token \(error.localizedDescription)")
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
        } else {
            completionHandler(.noData)
        }
    }
    
    // MARK: - Background fetch
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        backgroundFetch = application.beginBackgroundTask (expirationHandler: { [weak self] in
            log("AppDelegate background: Background task expired")
            application.endBackgroundTask(self?.backgroundFetch ?? .invalid)
            self?.backgroundFetch = nil
        })
        fetchRemoteValues(background: true)
            .subscribe(onSuccess: { [weak self] _ in
                log("AppDelegate background: Remote config updated")
                completionHandler(.newData)
                application.endBackgroundTask(self?.backgroundFetch ?? .invalid)
                self?.backgroundFetch = nil
                log("AppDelegate background: newData")
            }, onError: { [weak self] error in
                log("AppDelegate background: Remote config error")
                completionHandler(.failed)
                application.endBackgroundTask(self?.backgroundFetch ?? .invalid)
                self?.backgroundFetch = nil
                log("AppDelegate background: failed")
            })
            .disposed(by: bag)
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
        fetchRemoteValues(background: false)
            .subscribe(onSuccess: { [weak self] _ in
                self?.checkFetchedMinSupportedVersion()
            })
            .disposed(by: bag)

        let configuration = Realm.Configuration(
            schemaVersion: 3,
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
        } else if RemoteValues.shouldCheckOSVersion, Version.currentOSVersion < Version("13.5") {
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
        } else if RemoteValues.shouldCheckOSVersion, Version.currentOSVersion < Version("13.5") {
            rootViewController = UIStoryboard(name: "ForceUpdate", bundle: nil).instantiateViewController(withIdentifier: "ForceOSUpdateVC")
            presentingAnyForceUpdateScreen = true
        } else if RemoteValues.minSupportedVersion > App.appVersion {
            rootViewController = UIStoryboard(name: "ForceUpdate", bundle: nil).instantiateViewController(withIdentifier: "ForceUpdateVC")
            presentingAnyForceUpdateScreen = true
        } else if KeychainService.eHRID == nil {
            if Auth.auth().currentUser != nil {
                rootViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "OnboardingActivatedUser")
                shouldPresentNews = true
            } else {
                rootViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController()
            }
        } else {
            rootViewController = UIStoryboard(name: "Active", bundle: nil).instantiateInitialViewController()
        }

        window.rootViewController = rootViewController

        if shouldPresentNews, !AppSettings.v2_0NewsLaunched {
            AppSettings.v2_0NewsLaunched = true
            guard let newsViewController = UIStoryboard(name: "News", bundle: nil).instantiateInitialViewController() else { return }
            rootViewController?.present(newsViewController, animated: true)
        }
    }

    func setupBackgroundMode() {
        let dateFormat = DateFormatter()
        dateFormat.timeStyle = .short
        dateFormat.dateStyle = .short

        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundTaskIdentifier, using: .main) { task in

            // Notify the user if bluetooth is off
            Self.dependency.exposureService.showBluetoothOffUserNotificationIfNeeded()

            func reportFailure(_ error: Error) {
                task.setTaskCompleted(success: false)
                Log.log("AppDelegate: Failed to detect exposures \(error)")
            }

            // Perform the exposure detection
            let progress = Self.dependency.reporter.downloadKeys { result in
                switch result {
                case .success(let URLs):
                    Self.dependency.reporter.fetchExposureConfiguration { result in
                        switch result {
                        case .success(let configuration):
                            AppDelegate.dependency.exposureService.detectExposures(
                                configuration: configuration,
                                URLs: URLs
                            ) { result in
                                switch result {
                                case .success(var exposures):
                                    exposures.sort { $0.date < $1.date }

                                    let realm = try! Realm()
                                    var result = ""
                                    for exposure in exposures {
                                        let signals = exposure.attenuationDurations.map { "\($0)" }
                                        result += "EXP: \(dateFormat.string(from: exposure.date))" +
                                            ", dur: \(exposure.duration), risk \(exposure.totalRiskScore), tran level: \(exposure.transmissionRiskLevel)\n"
                                            + "attenuation value: \(exposure.attenuationValue)\n"
                                            + "signal attenuations: \(signals.joined(separator: ", "))\n"
                                    }
                                    try! realm.write() {
                                        exposures.forEach { realm.add(ExposureRealm($0)) }
                                    }
                                    if result == "" {
                                        result = "None";
                                    }

                                    log("EXP: \(exposures)")
                                    log("EXP: \(result)")

                                    let content = UNMutableNotificationContent()
                                    content.title = "Exposures"
                                    content.body = result
                                    content.sound = .default
                                    let request = UNNotificationRequest(identifier: "exposures", content: content, trigger: nil)
                                    UNUserNotificationCenter.current().add(request) { error in
                                        DispatchQueue.main.async {
                                            if let error = error {
                                                Log.log("AppDelegate: Error showing error user notification \(error)")
                                            }
                                        }
                                    }

                                    task.setTaskCompleted(success: true)
                                case .failure(let error):
                                    reportFailure(error)
                                }
                            }
                        case .failure(let error):
                            reportFailure(error)
                        }
                    }
                case .failure(let error):
                    reportFailure(error)
                }
            }

            // Handle running out of time
            task.expirationHandler = {
                progress.cancel()
                Log.log("Background task timeout")
            }

            // Schedule the next background task
            self.scheduleBackgroundTaskIfNeeded()
        }

        scheduleBackgroundTaskIfNeeded()
    }

    func scheduleBackgroundTaskIfNeeded() {
        guard Self.dependency.exposureService.authorizationStatus == .authorized else { return }
        let taskRequest = BGProcessingTaskRequest(identifier: Self.backgroundTaskIdentifier)
        taskRequest.requiresNetworkConnectivity = true

        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            Log.log("Background: Unable to schedule background task: \(error)")
        }
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
