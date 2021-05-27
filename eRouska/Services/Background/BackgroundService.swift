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
import FirebaseAuth
import FirebaseFunctions
import FirebaseCrashlytics

protocol HasBackgroundService {
    var background: BackgroundServicing { get }
}

protocol BackgroundServicing {

    var isRunning: Bool { get }

    var taskIdentifier: BackgroundTaskIdentifier { get }

    func registerTask(with taskIdentifier: BackgroundTaskIdentifier)
    func performTask()

    func scheduleBackgroundTaskIfNeeded(next: Bool)

}

final class BackgroundService: BackgroundServicing {

    // MARK: - Dependencies

    typealias Dependencies = HasExposureService & HasExposureList & HasReportService & HasFunctions

    private let dependencies: Dependencies

    // MARK: -

    private(set) var isRunning: Bool = false

    let taskIdentifier = BackgroundTaskIdentifier.exposureNotification

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        registerTask(with: taskIdentifier)
    }

    func registerTask(with taskIdentifier: BackgroundTaskIdentifier) {
        if #available(iOS 13, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier.schedulerIdentifier, using: .main) { task in
                log("BGTask: Start background check")

                let progress = self.performTask { success in
                    task.setTaskCompleted(success: success)
                }

                // Handle running out of time
                task.expirationHandler = {
                    self.scheduleBackgroundTaskIfNeeded(next: false)
                    progress.cancel()
                    task.setTaskCompleted(success: false)
                    log("AppDelegate: BG timeout")
                }

                // Schedule the next background task
                self.scheduleBackgroundTaskIfNeeded(next: true)
            }
        }
    }

    func performTask() {
        guard !isRunning else { return }
        _ = self.performTask(callback: nil)
    }

    func scheduleBackgroundTaskIfNeeded(next: Bool) {
        Self.scheduleDeadmanNotification()

        if #available(iOS 13, *) {
            guard dependencies.exposure.authorizationStatus == .authorized else { return }
            let taskRequest = BGProcessingTaskRequest(identifier: taskIdentifier.schedulerIdentifier)
            taskRequest.requiresNetworkConnectivity = true
            taskRequest.requiresExternalPower = false
            if next {
                // start after next 8 hours
                let earliestBeginDate = Date(timeIntervalSinceNow: 8 * 60 * 60)
                taskRequest.earliestBeginDate = earliestBeginDate
                log("Background: Schedule next task to: \(earliestBeginDate)")
            }

            do {
                try BGTaskScheduler.shared.submit(taskRequest)
            } catch {
                log("Background: Unable to schedule background task: \(error)")
            }
        } else {
            dependencies.exposure.setLaunchActivityHandler { activityFlags in
                if activityFlags.contains(.periodicRun) {
                    log("Background: Periodic activity callback called (iOS 12.5)")
                    self.performTask()
                }
            }
        }
    }

    // MARK: - Bluetooth notification

    func showBluetoothOffUserNotificationIfNeeded() {
        let notificationCenter = UNUserNotificationCenter.current()

        // bundleIdentifier is defined in Info.plist and can never be nil!
        guard let bundleID = Bundle.main.bundleIdentifier else {
            log("BGNotification: Could not access bundle identifier")
            return
        }
        let identifier = bundleID + ".notifications.bluetooth_off"

        if dependencies.exposure.authorizationStatus == .authorized, !dependencies.exposure.isBluetoothOn {
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
                        log("BGNotification: Error showing user notification \(error)")
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
            log("BGNotification: Could not access bundle identifier")
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
                    log("BGNotification: Error showing user notification \(error)")
                }
            }
        }
    }

}

private extension BackgroundService {

    typealias TaskCallback = (_ success: Bool) -> Void

    func performTask(callback: TaskCallback?) -> Progress {
        Events.keyExportDownloadStarted.logEvent()

        isRunning = true

        // Notify the user if bluetooth is off
        showBluetoothOffUserNotificationIfNeeded()

        func reportFailure(_ error: ReportError) {
            callback?(false)
            isRunning = false
            log("BGTask: failed to detect exposures \(error)")
            Crashlytics.crashlytics().record(error: error)
        }

        func reportSuccess() {
            callback?(true)
            isRunning = false

            AppSettings.lastProcessedDate = Date()
            Events.keyExportDownloadFinished.logEvent()
        }

        // Perform the exposure detection
        let keyURLs = AppSettings.efgsEnabled ? RemoteValues.keyExportEuTravellerUrls : RemoteValues.keyExportNonTravellerUrls
        return dependencies.reporter.downloadKeys(exportURLs: keyURLs, lastProcessedFileNames: AppSettings.lastProcessedFileNames) { report in
            log("BGTask: did download keys \(report)")

            var atLeastOneSuccess: Bool = false
            var URLs: [URL] = []
            for (_, success) in report.success {
                guard !success.URLs.isEmpty else {
                    atLeastOneSuccess = true
                    continue
                }
                URLs.append(contentsOf: success.URLs)
            }

            for (_, failure) in report.failures {
                reportFailure(failure)
            }

            if !URLs.isEmpty || atLeastOneSuccess {
                if !URLs.isEmpty {
                    self.dependencies.exposure.detectExposures(
                        configuration: RemoteValues.exposureConfiguration,
                        URLs: URLs
                    ) { result in
                        switch result {
                        case .success(let exposures):
                            self.handleExposures(exposures, countries: report.success)
                            reportSuccess()
                        case .failure(let error):
                            reportFailure(.generalError(error))
                        }
                    }
                } else {
                    self.handleExposures([], countries: report.success)
                    reportSuccess()
                }
            }
        }
    }

    func handleExposures(_ exposures: [Exposure], countries: ReportDownload.Success) {
        for (code, success) in countries {
            guard success.lastProcessedFileName != nil else { continue }
            AppSettings.lastProcessedFileNames[code] = success.lastProcessedFileName
        }

        guard !exposures.isEmpty else {
            log("EXP: no exposures, skip!")

            #if !PROD || DEBUG
            showExposureNotification(result: "EXP: No exposures detected, device is clear.")
            #endif
            return
        }

        try? dependencies.exposureList.add(exposures, detectionDate: Date())

        Auth.auth().currentUser?.getIDToken(completion: { token, error in
            if let token = token {
                let data = ["idToken": token]
                self.dependencies.functions.httpsCallable("RegisterNotification").call(data) { _, _ in }
            } else if let error = error {
                Crashlytics.crashlytics().record(error: error)
            }
        })

        #if !PROD || DEBUG

        var result = ""
        for exposure in exposures {
            let signals = exposure.attenuationDurations.map { "\($0)" }
            result += "EXP: \(DateFormatter.baseDateTimeFormatter.string(from: exposure.date))" +
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
            log("BGNotification: Could not access bundle identifier")
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
                    log("BGNotification: error showing error user notification \(error)")
                }
            }
        }

    }

}
