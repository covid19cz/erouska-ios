//
//  BackgroundService.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 17/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import BackgroundTasks

struct BackgroundService {

    let exposureService: ExposureServicing
    let reporter: ReportServicing

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

    // MARK: - Deadman notifications

    /// Taken from: https://github.com/corona-warn-app/cwa-app-ios
    /// Schedules a local notification to fire 36 hours from now.
    /// In case the background execution fails  there will be a backup notification for the
    /// user to be notified to open the app. If everything runs smoothly,
    /// the current notification will always be moved to the future, thus never firing.
    static func scheduleDeadmanNotification() {
        let notificationCenter = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("deadman_notificaiton_title", comment: "")
        content.body = NSLocalizedString("deadman_notificaiton_message", comment: "")
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
            if error != nil {
                Log.log("BGNotification: Deadman notification could not be scheduled.")
            }
        }
    }

}

private extension BackgroundService {

    func performTask(_ task: BGTask) -> Progress {
        // Notify the user if bluetooth is off
        exposureService.showBluetoothOffUserNotificationIfNeeded()

        func reportFailure(_ error: Error) {
            task.setTaskCompleted(success: false)
            Log.log("BGTask: failed to detect exposures \(error)")
        }

        // Perform the exposure detection
        return reporter.downloadKeys { result in
            Log.log("BGTask: did download keys \(result)")

            switch result {
            case .success(let URLs):
                self.reporter.fetchExposureConfiguration { result in
                    switch result {
                    case .success(let configuration):
                        self.exposureService.detectExposures(
                            configuration: configuration,
                            URLs: URLs
                        ) { result in
                            switch result {
                            case .success(var exposures):
                                exposures.sort { $0.date < $1.date }
                                self.handleExposures(exposures)

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
    }

    func handleExposures(_ exposures: [Exposure]) {
        let dateFormat = DateFormatter()
        dateFormat.timeStyle = .short
        dateFormat.dateStyle = .short

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
                    Log.log("BGTask: error showing error user notification \(error)")
                }
            }
        }
    }

}
