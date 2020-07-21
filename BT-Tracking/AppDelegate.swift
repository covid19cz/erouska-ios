//
//  AppDelegate.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 14/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
#if !targetEnvironment(macCatalyst)
import Firebase
import FirebaseAuth
import FirebaseFunctions
import FirebaseRemoteConfig
#endif
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
    
    // MARK: - Globals

    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    static var dependency = AppDependency()
    
    // MARK: - UIApplicationDelegate

    var window: UIWindow? = nil

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

        if Auth.isLoggedIn {
            Self.dependency.scannerStore.deleteOldRecordsIfNeeded()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        log("\n\n\n-BACKGROUND---------------------------\n")

        inBackgroundStage = true
        Self.dependency.scannerStore.appTermination.onNext(())
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Self.dependency.scannerStore.appTermination.onNext(())
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
        guard let buid = KeychainService.BUID else { return }
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

        #if !targetEnvironment(macCatalyst)

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

        #endif

        let configuration = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in

            }
        )

        Realm.Configuration.defaultConfiguration = configuration

        if Auth.isLoggedIn {
            Self.dependency.scannerStore.deleteOldRecordsIfNeeded()
        }
    }

    private func checkFetchedMinSupportedVersion() {
        if RemoteValues.minSupportedVersion > Version.currentAppVersion {
            advertiser.stop()
            scanner.stop()
            let viewController = UIStoryboard(name: "ForceUpdate", bundle: nil).instantiateViewController(withIdentifier: "ForceUpdateVC")
            viewController.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(viewController, animated: true)
        }
    }
    
    private func setupInterface() {
        let window = UIWindow()
        window.backgroundColor = .black
        window.makeKeyAndVisible()
        self.window = window

        let rootViewController: UIViewController?
        #if !targetEnvironment(macCatalyst)

        if Version.currentOSVersion < Version("13.5") {
            rootViewController = UIStoryboard(name: "ForceUpdate", bundle: nil).instantiateViewController(withIdentifier: "ForceOSUpdateVC")
        } else if RemoteValues.minSupportedVersion > Version.currentAppVersion {
            rootViewController = UIStoryboard(name: "ForceUpdate", bundle: nil).instantiateViewController(withIdentifier: "ForceUpdateVC")
        } else if !Auth.isLoggedIn {
            try? Auth.auth().signOut()
            rootViewController = UIStoryboard(name: "Signup", bundle: nil).instantiateInitialViewController()
        } else {
            rootViewController = UIStoryboard(name: "Active", bundle: nil).instantiateInitialViewController()
        }

        #else
        rootViewController = UIStoryboard(name: "Debug", bundle: nil).instantiateInitialViewController()
        #endif

        window.rootViewController = rootViewController
    }

    private func setupBackgroundMode() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundTaskIdentifier, using: .main) { task in

            // Notify the user if bluetooth is off
            Self.dependency.exposureService.showBluetoothOffUserNotificationIfNeeded()

            // Perform the exposure detection
            Self.dependency.exposureService.detectExposures { result in
                switch result {
                case .success:
                    task.setTaskCompleted(success: true)
                case let .failure(error):
                    task.setTaskCompleted(success: false)
                    Log.log("Failed to detect exposures \(error.localizedDescription)")
                }
            }

            // Handle running out of time
            task.expirationHandler = {
                Log.log("Background task timeout")
                // TODO: handle error, NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error")
            }

            // Schedule the next background task
            self.scheduleBackgroundTaskIfNeeded()
        }

        scheduleBackgroundTaskIfNeeded()
    }

    private  func scheduleBackgroundTaskIfNeeded() {
        guard Self.dependency.exposureService.authorizationStatus == .authorized else { return }
        let taskRequest = BGProcessingTaskRequest(identifier: Self.backgroundTaskIdentifier)
        taskRequest.requiresNetworkConnectivity = true

        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            Log.log("Bakcground: Unable to schedule background task: \(error)")
        }
    }
    
    private func clearKeychainIfNeeded() {
        guard !AppSettings.appFirstTimeLaunched else { return }
        AppSettings.appFirstTimeLaunched = true
        KeychainService.BUID = nil
        KeychainService.TUIDs = nil
    }
}
