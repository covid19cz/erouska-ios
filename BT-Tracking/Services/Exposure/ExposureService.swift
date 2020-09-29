//
//  ExposureService.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 30/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification
import RxSwift

protocol ExposureServicing: AnyObject {

    var readyToUse: Completable { get }

    // Activation
    typealias Callback = (Error?) -> Void
    
    var isActive: Bool { get }
    var isEnabled: Bool { get }

    var status: ENStatus { get }
    var authorizationStatus: ENAuthorizationStatus { get }

    typealias ActivationCallback = (ExposureError?) -> Void
    func activate(callback: ActivationCallback?)
    func deactivate(callback: Callback?)

    // Keys
    typealias KeysCallback = (_ result: Result<[ExposureDiagnosisKey], ExposureError>) -> Void
    func getDiagnosisKeys(callback: @escaping KeysCallback)
    func getTestDiagnosisKeys(callback: @escaping KeysCallback)

    // Detection
    typealias DetectCallback = (Result<[Exposure], Error>) -> Void
    var detectingExposures: Bool { get }
    func detectExposures(configuration: ExposureConfiguration, URLs: [URL], callback: @escaping DetectCallback)

    // Bluetooth
    var isBluetoothOn: Bool { get }

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

    func activate(callback: ActivationCallback?) {
        print("ExposureService: activating")
        guard !isEnabled, !isActive else {
            callback?(nil)
            return
        }

        let activationCallback: ENErrorHandler = { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                if let code = ENError.Code(rawValue: (error as NSError).code) {
                    callback?(ExposureError.activationError(code))
                } else if self.manager.exposureNotificationStatus == .restricted {
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
        case .disabled, .unknown, .restricted, .unauthorized:
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
                callback(.failure(ExposureError.error(error)))
            } else if keys?.isEmpty == true {
                callback(.failure(ExposureError.noData))
            } else if let keys = keys {
                callback(.success(keys.map { ExposureDiagnosisKey(key: $0) }))
            }
        }
    }

    private(set) var detectingExposures = false

    func detectExposures(configuration: ExposureConfiguration, URLs: [URL], callback: @escaping DetectCallback) {
        guard !detectingExposures else {
            callback(.failure(ExposureError.alreadyRunning))
            return
        }
        detectingExposures = true

        func finish(error: Error? = nil, exposures: [Exposure] = []) {
            if let error = error {
                callback(.failure(error))
            } else {
                callback(.success(exposures))
            }

            URLs.forEach { try? FileManager.default.removeItem(at: $0) }
            detectingExposures = false
        }

        log("ExposureService detectExposures")
        self.manager.detectExposures(configuration: configuration.configuration, diagnosisKeyURLs: URLs) { summary, error in
            if let error = error {
                finish(error: error)
            } else if let summary = summary {
                log("ExposureService summary \(summary)")

                let computedThreshold: Double = (Double(truncating: summary.attenuationDurations[0]) * configuration.factorLow +
                    Double(truncating: summary.attenuationDurations[1]) * configuration.factorHigh) / 60 // (minute)
                log("ExposureService Summary for day \(summary.daysSinceLastExposure) : \(summary.debugDescription) computed threshold: \(computedThreshold) (low:\(configuration.factorLow) high: \(configuration.factorHigh)) required \(configuration.triggerThreshold)")

                if computedThreshold >= Double(configuration.triggerThreshold) {
                    log("ExposureService Summary meets requirements")

                    guard summary.matchedKeyCount != 0 else {
                        finish()
                        return
                    }
                    log("ExposureService getExposureInfo")

                    self.manager.getExposureInfo(summary: summary, userExplanation: Localizable("exposure_detected_title")) { exposures, error in
                        if let error = error {
                            finish(error: error)
                        } else if let exposures = exposures {
                            finish(exposures: exposures.map {
                                Exposure(
                                    id: UUID(),
                                    date: $0.date,
                                    duration: $0.duration,
                                    totalRiskScore: $0.totalRiskScore,
                                    transmissionRiskLevel: $0.transmissionRiskLevel,
                                    attenuationValue: $0.attenuationValue,
                                    attenuationDurations: $0.attenuationDurations.map { $0.intValue }
                                )
                            })
                            log("ExposureService Exposures \(exposures)")
                        } else {
                            finish(error: ExposureError.noData)
                        }
                    }
                } else {
                    log("ExposureService Summary does not meet requirements")
                    finish()
                }
            } else {
                finish(error: ExposureError.noData)
            }
        }
    }

    // MARK: - Bluetooth

    var isBluetoothOn: Bool {
        return manager.exposureNotificationStatus != .bluetoothOff
    }

}
