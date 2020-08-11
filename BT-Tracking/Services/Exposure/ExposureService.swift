//
//  ExposureService.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 30/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification
import UserNotifications
import RxSwift

protocol ExposureServicing: class {

    var readyToUse: Completable { get }

    // Activation
    typealias Callback = (Error?) -> Void
    
    var isActive: Bool { get }
    var isEnabled: Bool { get }

    var status: ENStatus { get }
    var authorizationStatus: ENAuthorizationStatus { get }

    typealias ActivationCallback = (ExposureError?) -> Void
    func activate(callback: Callback?)
    func deactivate(callback: Callback?)

    // Keys
    typealias KeysCallback = (_ result: Result<[ExposureDiagnosisKey], Error>) -> Void
    func getDiagnosisKeys(callback: @escaping KeysCallback)
    func getTestDiagnosisKeys(callback: @escaping KeysCallback)

    // Detection
    typealias DetectCallback = (Result<[Exposure], Error>) -> Void
    var detectingExposures: Bool { get }
    func detectExposures(configuration: ENExposureConfiguration, URLs: [URL], callback: @escaping DetectCallback)

    // Bluetooth
    var isBluetoothOn: Bool { get }
    func showBluetoothOffUserNotificationIfNeeded()

}

final class ExposureService: ExposureServicing {

    var readyToUse: Completable

    typealias Callback = (Error?) -> Void

    private var manager: ENManager

    var isActive: Bool {
        return [ENStatus.active, .paused].contains(manager.exposureNotificationStatus)
    }

    var isEnabled: Bool {
        return manager.exposureNotificationEnabled
    }

    var status: ENStatus {
        return manager.exposureNotificationStatus
    }

    var authorizationStatus: ENAuthorizationStatus {
        return ENManager.authorizationStatus
    }

    init() {
        manager = ENManager()
        readyToUse = Completable.create { [manager] completable in
            manager.activate { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }

    deinit {
        manager.invalidate()
    }

    func activate(callback: Callback?) {
        print("ExposureService: activating")
        guard !isEnabled, !isActive else {
            callback?(nil)
            return
        }

        let activationCallback: ENErrorHandler = { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                if self.manager.exposureNotificationStatus == .restricted {
                    callback?(ExposureError.restrictedAccess)
                } else {
                    callback?(ExposureError.error(error))
                }
                return
            }

            DispatchQueue.main.async {
                callback?(nil)
            }
        }

        switch manager.exposureNotificationStatus {
        case .active, .paused:
            callback?(nil)
        case .unauthorized:
            manager.setExposureNotificationEnabled(true, completionHandler: activationCallback)
        case .disabled, .unknown, .restricted:
            // Restricted should be not "activatable" but on actual device it always shows as restricted before activation
            manager.setExposureNotificationEnabled(true, completionHandler: activationCallback)
        case .bluetoothOff:
            callback?(ExposureError.bluetoothOff)
        @unknown default:
            callback?(ExposureError.unknown)
        }
    }

    func deactivate(callback: Callback?) {
        print("ExposureService: deactivating")
        guard isEnabled else {
            callback?(nil)
            return
        }

        manager.setExposureNotificationEnabled(false) { error in
            guard error == nil else {
                callback?(error)
                return
            }
            callback?(nil)
         }
    }

    func getDiagnosisKeys(callback: @escaping KeysCallback) {
        manager.getDiagnosisKeys(completionHandler: keysCallback(callback))
    }

    func getTestDiagnosisKeys(callback: @escaping KeysCallback) {
        manager.getTestDiagnosisKeys(completionHandler: keysCallback(callback))
    }

    private func keysCallback(_ callback: @escaping KeysCallback) -> ENGetDiagnosisKeysHandler {
        return { keys, error in
            if let error = error {
                callback(.failure(error))
            } else if keys?.isEmpty == true {
                callback(.failure(ExposureError.noData))
            } else if let keys = keys {
                callback(.success(keys.map { ExposureDiagnosisKey(key: $0) }))
            }
        }
    }

    private(set) var detectingExposures = false

    func detectExposures(configuration: ENExposureConfiguration, URLs: [URL], callback: @escaping DetectCallback) {
        guard !detectingExposures else {
            callback(.failure(ExposureError.alreadyRunning))
            return
        }
        detectingExposures = true

        log("ExposureService detectExposures")
        self.manager.detectExposures(configuration: configuration, diagnosisKeyURLs: URLs) { summary, error in
            if let error = error {
                self.detectingExposures = false
                callback(.failure(error))
                return
            } else if let summary = summary {
                log("ExposureService summary \(summary)")
                let userExplanation = NSLocalizedString("Bylo detekovano nakazeni!", comment: "User notification")
                log("ExposureService getExposureInfo")
                self.manager.getExposureInfo(summary: summary, userExplanation: userExplanation) { exposures, error in
                    if let error = error {
                        self.detectingExposures = false
                        callback(.failure(error))
                        return
                    }

                    log("ExposureService Exposures \(exposures ?? [])")

                    let newExposures = (exposures ?? []).map { exposure in
                        Exposure(
                            date: exposure.date,
                            duration: exposure.duration,
                            totalRiskScore: exposure.totalRiskScore,
                            transmissionRiskLevel: exposure.transmissionRiskLevel,
                            attenuationValue: exposure.attenuationValue,
                            attenuationDurations: exposure.attenuationDurations.map { $0.intValue }
                        )
                    }
                    self.detectingExposures = false
                    callback(.success((newExposures)))
                }
            } else {
                self.detectingExposures = false
                callback(.failure(ExposureError.noData))
            }
        }
    }

    // MARK: - Bluetooth

    var isBluetoothOn: Bool {
        return manager.exposureNotificationStatus != .bluetoothOff
    }

    func showBluetoothOffUserNotificationIfNeeded() {
        let identifier = "bluetooth_off"
        if ENManager.authorizationStatus == .authorized, manager.exposureNotificationStatus == .bluetoothOff {
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("bluetooth_off_title", comment: "bluetooth_off_title")
            content.body = NSLocalizedString("bluetooth_off_body", comment: "bluetooth_off_body")
            content.sound = .default
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        Log.log("ExposureService: Error showing error user notification \(error)")
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        }
    }

}
