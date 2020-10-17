//
//  BackgroundService.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 17/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import UIKit
import BackgroundTasks
import FirebaseFunctions
import FirebaseAnalytics

final class BackgroundService {

    let exposureService: ExposureServicing
    let reporter: ReportServicing
    private(set) var isRunning: Bool = false

    let taskIdentifier = BackgroundTaskIdentifier.exposureNotification

    init(exposureService: ExposureServicing, reporter: ReportServicing) {
        self.exposureService = exposureService
        self.reporter = reporter

        registerTask(with: taskIdentifier)
    }

    func registerTask(with taskIdentifier: BackgroundTaskIdentifier) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier.schedulerIdentifier, using: .main) { task in
            Log.log("BGTask: Start background check")

            let progress = self.performTask(task)

            // Handle running out of time
            task.expirationHandler = {
                self.scheduleBackgroundTaskIfNeeded(next: false)
                progress.cancel()
                task.setTaskCompleted(success: false)
                Log.log("AppDelegate: BG timeout")
            }

            // Schedule the next background task
            self.scheduleBackgroundTaskIfNeeded(next: true)
        }
    }

    func performTask() {
        guard !isRunning else { return }
        _ = self.performTask(nil)
    }

    func scheduleBackgroundTaskIfNeeded(next: Bool = false) {
        Self.scheduleDeadmanNotification()

        guard exposureService.authorizationStatus == .authorized else { return }
        let taskRequest = BGProcessingTaskRequest(identifier: taskIdentifier.schedulerIdentifier)
        taskRequest.requiresNetworkConnectivity = true
        taskRequest.requiresExternalPower = false
        if next {
            // start after next 8 hours
            let earliestBeginDate = Date(timeIntervalSinceNow: 8 * 60 * 60)
            taskRequest.earliestBeginDate = earliestBeginDate
            Log.log("Background: Schedule next task to: \(earliestBeginDate)")
        }

        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            Log.log("Background: Unable to schedule background task: \(error)")
        }
    }

    // MARK: - Bluetooth notification

    func showBluetoothOffUserNotificationIfNeeded() {
        let notificationCenter = UNUserNotificationCenter.current()

        // bundleIdentifier is defined in Info.plist and can never be nil!
        guard let bundleID = Bundle.main.bundleIdentifier else {
            Log.log("BGNotification: Could not access bundle identifier")
            return
        }
        let identifier = bundleID + ".notifications.bluetooth_off"

        if exposureService.authorizationStatus == .authorized, !exposureService.isBluetoothOn {
            let content = UNMutableNotificationContent()
            content.title = L10n.bluetoothOffTitle
            content.body = L10n.bluetoothOffBody
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: nil

            )
            notificationCenter.add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        Log.log("BGNotification: Error showing user notification \(error)")
                    }
                }
            }
        } else {
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        }
    }

    // MARK: - Deadman notification

    /// Taken from: https://github.com/corona-warn-app/cwa-app-ios
    /// Schedules a local notification to fire 36 hours from now.
    /// In case the background execution fails  there will be a backup notification for the
    /// user to be notified to open the app. If everything runs smoothly,
    /// the current notification will always be moved to the future, thus never firing.
    static func scheduleDeadmanNotification() {
        let notificationCenter = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = L10n.deadmanNotificaitonTitle
        content.body = L10n.deadmanNotificaitonBody
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 36 * 60 * 60,
            repeats: false
        )

        // bundleIdentifier is defined in Info.plist and can never be nil!
        guard let bundleID = Bundle.main.bundleIdentifier else {
            Log.log("BGNotification: Could not access bundle identifier")
            return
        }

        let request = UNNotificationRequest(
            identifier: bundleID + ".notifications.deadman",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    Log.log("BGNotification: Error showing user notification \(error)")
                }
            }
        }
    }

}

private extension BackgroundService {

    func performTask(_ task: BGTask?) -> Progress {
        Analytics.logEvent("key_export_download_started", parameters: nil)

        isRunning = true

        // Notify the user if bluetooth is off
        showBluetoothOffUserNotificationIfNeeded()

        func reportFailure(_ error: Error) {
            task?.setTaskCompleted(success: false)
            isRunning = false
            Log.log("BGTask: failed to detect exposures \(error)")
        }

        // Perform the exposure detection
        return reporter.downloadKeys(lastProcessedFileName: AppSettings.lastProcessedFileName) { result in
            Log.log("BGTask: did download keys \(result)")

            switch result {
            case .success(let keys):
                guard !keys.URLs.isEmpty else {
                    AppSettings.lastProcessedDate = Date()

                    self.isRunning = false

                    task?.setTaskCompleted(success: true)
                    return
                }

                self.exposureService.detectExposures(
                    configuration: RemoteValues.exposureConfiguration,
                    URLs: keys.URLs
                ) { result in
                    switch result {
                    case .success(let exposures):
                        AppSettings.lastProcessedDate = Date()

                        self.handleExposures(exposures, lastProcessedFileName: keys.lastProcessedFileName)
                        self.isRunning = false

                        task?.setTaskCompleted(success: true)

                        Analytics.logEvent("key_export_download_finished", parameters: nil)
                    case .failure(let error):
                        reportFailure(error)
                    }
                }
            case .failure(let error):
                reportFailure(error)
            }
        }
    }

    func handleExposures(_ exposures: [Exposure], lastProcessedFileName: String?) {
        if let fileName = lastProcessedFileName {
            AppSettings.lastProcessedFileName = fileName
        }

        guard !exposures.isEmpty else {
            log("EXP: no exposures, skip!")

            #if !PROD || DEBUG
            showExposureNotification(result: "EXP: No exposures detected, device is clear.")
            #endif
            return
        }

        try? ExposureList.add(exposures, detectionDate: Date())

        let data = ["idToken": KeychainService.token]
        AppDelegate.dependency.functions.httpsCallable("RegisterNotification").call(data) { _, _ in }

        #if !PROD || DEBUG
        let dateFormat = DateFormatter()
        dateFormat.timeStyle = .short
        dateFormat.dateStyle = .short

        var result = ""
        for exposure in exposures {
            let signals = exposure.attenuationDurations.map { "\($0)" }
            result += "EXP: \(dateFormat.string(from: exposure.date))" +
                ", dur: \(exposure.duration), risk \(exposure.totalRiskScore), tran level: \(exposure.transmissionRiskLevel)\n"
                + "attenuation value: \(exposure.attenuationValue)\n"
                + "signal attenuations: \(signals.joined(separator: ", "))\n"
        }
        if result.isEmpty {
            result = "None"
        }

        log("EXP: \(exposures)")
        log("EXP: \(result)")

        showExposureNotification(result: result)
        #endif
    }

    func showExposureNotification(result: String) {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            Log.log("BGNotification: Could not access bundle identifier")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Exposures"
        content.body = result
        content.sound = .default
        let request = UNNotificationRequest(identifier: bundleID + ".notifications.exposures", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    Log.log("BGNotification: error showing error user notification \(error)")
                }
            }
        }

    }

}
