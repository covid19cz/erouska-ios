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
        manager.activate { _ in
            if ENManager.authorizationStatus == .authorized && !self.manager.exposureNotificationEnabled {
                self.manager.setExposureNotificationEnabled(true) { _ in
                    // No error handling for attempts to enable on launch
                }
            }
        }
    }

    deinit {
        manager.invalidate()
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
            manager.setExposureNotificationEnabled(true) { [weak self] error in
                guard error == nil else {
                    callback?(error)
                    return
                }

                guard let self = self else { return }
                log("Trace \(self.isActive)")
                log("Trace \(self.isEnabled)")
                log("Trace \(self.status)")

                self.manager.activate { error in
                    guard error == nil else {
                        callback?(error)
                        return
                    }
                    callback?(nil)
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
        #if DEBUG
        manager.getTestDiagnosisKeys(completionHandler: callback)
        #else
        manager.getDiagnosisKeys(completionHandler: callback)
        #endif
    }

    func resetAll(callback: Callback?) {

    }

}
