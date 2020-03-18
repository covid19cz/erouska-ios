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
#endif

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

    // MARK: - UIApplicationDelegate

    var window: UIWindow? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        log("\n\n\n-START--------------------------------\n")

        #if !targetEnvironment(macCatalyst)

        #if DEBUG
        #else
        FirebaseApp.configure()
        #endif

        #endif

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            
        }

        let generalCategory = UNNotificationCategory(
            identifier: "Scanning",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([generalCategory])

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        log("\n\n\n-FOREGROUND---------------------------\n")

        if backgroundTask != .invalid {
            application.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        inBackgroundStage = false
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("we are in the background...")
        log("\n\n\n-BACKGROUND---------------------------\n")

        inBackgroundStage = true
        
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
        log("\n\n\n-END----------------------------------\n")
    }

}
