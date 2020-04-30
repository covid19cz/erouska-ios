//
//  ExposureService.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 30/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification

enum ExposureError: Error {
    case bluetoothOff
    case restrictedAccess
    case unknown
}

protocol ExposureServicing: class {

    typealias Callback = (Error?) -> Void
    
    var isActive: Bool { get }
    var isEnabled: Bool { get }

    @available(iOS 13.5, *)
    var status: ENStatus { get }

    func activate(callback: Callback?)
    func deactivate(callback: Callback?)

    @available(iOS 13.5, *)
    func getDiagnosisKeys(callback: @escaping ENGetDiagnosisKeysHandler)

    func resetAll(callback: Callback?)

}

@available(iOS 13.5, *)
class ExposureService: ExposureServicing {

    typealias Callback = (Error?) -> Void

    private var manager: ENManager
    private var session: ENExposureDetectionSession

    var isActive: Bool {
        return manager.exposureNotificationStatus == .active
    }

    var isEnabled: Bool {
        return manager.exposureNotificationEnabled
    }

    var status: ENStatus {
        return manager.exposureNotificationStatus
    }

    init() {
        manager = ENManager()
        session = ENExposureDetectionSession()
    }

    func activate(callback: Callback?) {
        switch manager.exposureNotificationStatus {
        case .active:
            callback?(nil)
        case .disabled:
            manager.setExposureNotificationEnabled(true) { error in
                guard error == nil else {
                    callback?(error)
                    return
                }
            }
        case .unknown:
            manager.activate { [weak self] error in
                guard error == nil else {
                    callback?(error)
                    return
                }

                self?.manager.setExposureNotificationEnabled(true) { [weak self] error in
                    guard error == nil else {
                        callback?(error)
                        return
                    }

                    guard let self = self else { return }
                    log("Trace \(self.isActive)")
                    log("Trace \(self.isEnabled)")
                    log("Trace \(self.status)")

                    self.session.activate { [weak self] error in
                        guard error == nil else {
                            callback?(error)
                            return
                        }
                        callback?(nil)
                    }
                }
            }
        case .restricted:
            callback?(ExposureError.restrictedAccess)
        case .bluetoothOff:
            callback?(ExposureError.bluetoothOff)
        @unknown default:
            callback?(ExposureError.unknown)
        }
    }

    func deactivate(callback: Callback?) {
        session.invalidate()
        session = ENExposureDetectionSession()

        manager.setExposureNotificationEnabled(false) { [weak self] error in
            guard error == nil else {
                callback?(error)
                return
            }

            self?.manager.invalidate()
            self?.manager = ENManager()

            callback?(nil)
         }
    }

    func getDiagnosisKeys(callback: @escaping ENGetDiagnosisKeysHandler) {
        manager.getDiagnosisKeys(completionHandler: callback)
    }

    func resetAll(callback: Callback?) {
        manager.resetAllData { error in
            callback?(error)
        }
    }

}
