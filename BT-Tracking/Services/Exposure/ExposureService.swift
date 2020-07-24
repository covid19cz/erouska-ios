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
import CommonCrypto
import Security

protocol ExposureServicing: class {

    // Activation
    typealias Callback = (Error?) -> Void
    
    var isActive: Bool { get }
    var isEnabled: Bool { get }

    var status: ENStatus { get }
    var authorizationStatus: ENAuthorizationStatus { get }

    func activate(callback: Callback?)
    func deactivate(callback: Callback?)

    // Keys
    typealias KeysCallback = (_ result: Result<[ExposureDiagnosisKey], Error>) -> Void
    func getDiagnosisKeys(callback: @escaping KeysCallback)
    func getTestDiagnosisKeys(callback: @escaping KeysCallback)

    // Detection
    typealias DetectCallback = (Result<[Exposure], Error>) -> Void
    var detectingExposures: Bool { get }
    func detectExposures(configuration: ENExposureConfiguration, keys: [ExposureDiagnosisKey], callback: @escaping DetectCallback)

    // Bluetooth
    var isBluetoothOn: Bool { get }
    func showBluetoothOffUserNotificationIfNeeded()

}

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

    var authorizationStatus: ENAuthorizationStatus {
        return ENManager.authorizationStatus
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
        case .active, .paused:
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
                log("Exposure isActive: \(self.isActive)")
                log("Exposure isEnabled: \(self.isEnabled)")
                log("Exposure rawStatus: \(self.status.rawValue)")

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

    func detectExposures(configuration: ENExposureConfiguration, keys: [ExposureDiagnosisKey], callback: @escaping DetectCallback) {
        guard !detectingExposures else {
            callback(.failure(ExposureError.alreadyRunning))
            return
        }
        detectingExposures = true

        log("ExposureService archiveDiagnosisKeys")
        archiveDiagnosisKeys(keys: keys) { result in
            switch result {
            case .success(let URLs):
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
            case .failure(let error):
                self.detectingExposures = false
                callback(.failure(error))
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

private extension ExposureService {

    static let privateKeyECData = Data(base64Encoded: """
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgKJNe9P8hzcbVkoOYM4hJFkLERNKvtC8B40Y/BNpfxMeh\
    RANCAASfuKEs4Z9gHY23AtuMv1PvDcp4Uiz6lTbA/p77if0yO2nXBL7th8TUbdHOsUridfBZ09JqNQYKtaU9BalkyodM
    """)!

    func archiveDiagnosisKeys(keys: [ExposureDiagnosisKey], completion: (Result<[URL], Error>) -> Void) {
        let fileName = UUID().uuidString

        do {
            let attributes = [
                kSecAttrKeyType: kSecAttrKeyTypeEC,
                kSecAttrKeyClass: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits: 256
                ] as CFDictionary

            var cfError: Unmanaged<CFError>? = nil

            let privateKeyData = Self.privateKeyECData.suffix(65) + Self.privateKeyECData.subdata(in: 36..<68)
            guard let secKey = SecKeyCreateWithData(privateKeyData as CFData, attributes, &cfError) else {
                throw cfError!.takeRetainedValue()
            }

            let signatureInfo = SignatureInfo.with { signatureInfo in
                signatureInfo.appBundleID = Bundle.main.bundleIdentifier!
                signatureInfo.verificationKeyVersion = "v1"
                signatureInfo.verificationKeyID = "310"
                signatureInfo.signatureAlgorithm = "SHA256withECDSA"
            }

            // In a real implementation, the file at remoteURL would be downloaded from a server
            // This sample generates and saves a binary and signature pair of files based on the locally stored diagnosis keys
            let export = TemporaryExposureKeyExport.with { export in
                export.batchNum = 1
                export.batchSize = 1
                export.region = "310"
                export.signatureInfos = [signatureInfo]
                export.keys = keys.shuffled().map { diagnosisKey in
                    TemporaryExposureKey.with { temporaryExposureKey in
                        temporaryExposureKey.keyData = diagnosisKey.keyData
                        temporaryExposureKey.transmissionRiskLevel = Int32(diagnosisKey.transmissionRiskLevel)
                        temporaryExposureKey.rollingStartIntervalNumber = Int32(diagnosisKey.rollingStartNumber)
                        temporaryExposureKey.rollingPeriod = Int32(diagnosisKey.rollingPeriod)
                    }
                }
            }

            let exportData = "EK Export v1    ".data(using: .utf8)! + (try export.serializedData())

            var exportHash = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            _ = exportData.withUnsafeBytes { exportDataBuffer in
                exportHash.withUnsafeMutableBytes { exportHashBuffer in
                    CC_SHA256(exportDataBuffer.baseAddress, CC_LONG(exportDataBuffer.count), exportHashBuffer.bindMemory(to: UInt8.self).baseAddress)
                }
            }

            guard let signedHash = SecKeyCreateSignature(secKey, .ecdsaSignatureDigestX962SHA256, exportHash as CFData, &cfError) as Data? else {
                throw cfError!.takeRetainedValue()
            }

            let tekSignatureList = TEKSignatureList.with { tekSignatureList in
                tekSignatureList.signatures = [TEKSignature.with { tekSignature in
                    tekSignature.signatureInfo = signatureInfo
                    tekSignature.signature = signedHash
                    tekSignature.batchNum = 1
                    tekSignature.batchSize = 1
                    }]
            }

            let cachesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let localBinURL = cachesDirectory.appendingPathComponent(fileName + ".bin")
            try exportData.write(to: localBinURL)

            let localSigURL = cachesDirectory.appendingPathComponent(fileName + ".sig")
            try tekSignatureList.serializedData().write(to: localSigURL)

            completion(.success([localBinURL, localSigURL]))
        } catch {
            completion(.failure(error))
        }
    }

}
