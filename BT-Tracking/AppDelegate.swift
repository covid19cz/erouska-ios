//
//  AppDelegate.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 14/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var inBackgroundStage: Bool = false

    private var rootWindow: UIWindow? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        log("\n\n\n-START--------------------------------\n")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let window = UIWindow()
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        window.rootViewController = storyboard.instantiateInitialViewController()
        self.rootWindow = window

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

            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        log("\n\n\n-END----------------------------------\n")
    }

}
