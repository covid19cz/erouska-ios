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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var allowBackgroundTask: Bool = false
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
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

    private(set) lazy var advertiser: BTAdvertising = BTAdvertiser(
        TUIDs: KeychainService.TUIDs ?? [],
        IDRotation: AppSettings.TUIDRotation
    )
    private(set) lazy var scanner: BTScannering = BTScanner()
    lazy var scannerStore: ScannerStore = {
        let store = ScannerStore(
            scanningPeriod: RemoteValues.collectionSeconds,
            dataPurgeInterval: RemoteValues.persistDataInterval
        )
        AppDelegate.shared.scanner.add(delegate: store)
        return store
    }()
    private(set) var deviceToken: Data?

    #if !targetEnvironment(macCatalyst)
    private(set) lazy var functions = Functions.functions(region: AppSettings.firebaseRegion)
    #endif

    // MARK: - Public

    func resetAdvertising() {
        guard KeychainService.BUID != nil else { return }
        let wasRunning = advertiser.isRunning
        advertiser.stop()
        advertiser = BTAdvertiser(
            TUIDs: KeychainService.TUIDs ?? [],
            IDRotation: AppSettings.TUIDRotation
        )

        if wasRunning {
            advertiser.start()
        }
    }
    
    // MARK: - UIApplicationDelegate

    var window: UIWindow? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        log("\n\n\n-START--------------------------------\n")

        clearKeychainIfNeeded()
        generalSetup()
        setupInterface()
        setupBackgroundMode(for: application)
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        log("\n\n\n-FOREGROUND---------------------------\n")

        if backgroundTask != .invalid {
            application.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        inBackgroundStage = false

        if Auth.isLoggedIn {
            scannerStore.deleteOldRecordsIfNeeded()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        log("\n\n\n-BACKGROUND---------------------------\n")

        inBackgroundStage = true
        scannerStore.appTermination.onNext(())
        
        guard allowBackgroundTask else { return }
        backgroundTask = application.beginBackgroundTask(withName: "BT") {
            log("\n\n\n-EXPIRATION TASK---------------------------\n")
        }

        DispatchQueue.global(qos: .background).async {
            while(true) {
                if self.inBackgroundStage == false {
                    log("\n\n\n-END TASK---------------------------\n")
                    break
                }
            }

            DispatchQueue.main.async {
                application.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = .invalid
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        scannerStore.appTermination.onNext(())
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
        self.deviceToken = deviceToken

        // update token on server
        guard let buid = KeychainService.BUID else { return }
        let data: [String: Any] = [
            "buid": buid,
            "pushRegistrationToken": deviceToken.hexEncodedString()
        ]

        functions.httpsCallable("changePushToken").call(data) { result, error in
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
        fetchRemoteConfig()
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
        setupFirebaseRemoteConfig()

        #endif

        let configuration = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in

            }
        )

        Realm.Configuration.defaultConfiguration = configuration

        if Auth.isLoggedIn {
            scannerStore.deleteOldRecordsIfNeeded()
        }
    }
    
    private func setupInterface() {
        let window = UIWindow()
        window.backgroundColor = .black
        window.makeKeyAndVisible()
        self.window = window

        let storyboard: UIStoryboard
        #if !targetEnvironment(macCatalyst)

        if !Auth.isLoggedIn {
            try? Auth.auth().signOut()
            storyboard = UIStoryboard(name: "Signup", bundle: nil)
        } else {
            storyboard = UIStoryboard(name: "Active", bundle: nil)
        }

        #else
        storyboard = UIStoryboard(name: "Debug", bundle: nil)
        #endif

        window.rootViewController = storyboard.instantiateInitialViewController()
    }

    private func setupBackgroundMode(for application: UIApplication) {
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        UIDevice.current.isProximityMonitoringEnabled = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func clearKeychainIfNeeded() {
        guard !AppSettings.appFirstTimeLaunched else { return }
        AppSettings.appFirstTimeLaunched = true
        KeychainService.BUID = nil
        KeychainService.TUIDs = nil
    }

    func fetchRemoteConfig() -> Single<Void> {
        return Single<Void>.create { single in
            RemoteConfig.remoteConfig().fetch(withExpirationDuration: 1800) { _, error in
                if let error = error {
                    log("AppDelegate background: Got an error fetching remote values \(error)")
                    single(.error(error))
                    return
                }
                RemoteConfig.remoteConfig().activate()
                log("AppDelegate background: Retrieved values from the Firebase Remote Config!")
                single(.success(()))
            }
            return Disposables.create()
        }
    }

}
