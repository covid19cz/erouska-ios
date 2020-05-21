//
//  ExposureService.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 30/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification
import CommonCrypto
import Security
import FirebaseStorage

protocol ExposureServicing: class {

    typealias Callback = (Error?) -> Void
    
    var isActive: Bool { get }
    var isEnabled: Bool { get }

    @available(iOS 13.5, *)
    var status: ENStatus { get }

    func activate(callback: Callback?)
    func deactivate(callback: Callback?)

    @available(iOS 13.5, *)
    typealias KeysCallback = (_ result: Result<[ExposureDiagnosisKey], Error>) -> Void

    @available(iOS 13.5, *)
    func getDiagnosisKeys(callback: @escaping KeysCallback)

    typealias DetectCallback = (Result<[Exposure], Error>) -> Void
    var detectingExposures: Bool { get }
    func detectExposures(callback: @escaping DetectCallback)

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
                log("Trace \(self.status.rawValue)")

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
        let innerCallbck: ENGetDiagnosisKeysHandler = { keys, error in
            if let error = error {
                callback(.failure(error))
            } else if keys?.isEmpty == true {
                callback(.failure(ExposureError.noData))
            } else if let keys = keys {
                callback(.success(keys.map { ExposureDiagnosisKey(key: $0) }))
            }
        }

        #if DEBUG
        manager.getTestDiagnosisKeys(completionHandler: innerCallbck)
        #else
        manager.getDiagnosisKeys(completionHandler: innerCallbck)
        #endif
    }

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

    private(set) var detectingExposures = false

    func detectExposures(callback: @escaping DetectCallback) {
        guard !detectingExposures else {
            callback(.failure(ExposureError.alreadyRunning))
            return
        }
        detectingExposures = true

        let path = "exposure"
        let fileName = "exposure.json"

        let storage = Storage.storage()
        let storageReference = storage.reference()

        let folderReference = storageReference.child(path)
        folderReference.listAll { result, error in
            if let error = error {
                self.detectingExposures = false
                log("Storage error: \(error)")
                callback(.failure(error))
                return
            }

            var count = 0
            var reports: [ExposureDiagnosisKey] = []
            let decoder = JSONDecoder()

            if result.prefixes.count == 0 {
                self.detectingExposures = false
                callback(.failure(ExposureError.noData))
                return
            }

            for folder in result.prefixes {
                folder.child(fileName).getData(maxSize: 1024 * 100) { data, error in
                    count += 1
                    if let error = error {
                        log("Storage error: \(error)")
                        return
                    }

                    let decoded = try? decoder.decode([ExposureDiagnosisKey].self, from: data ?? Data())
                    if let values = decoded {
                        reports.append(contentsOf: values)
                    }

                    if count == result.prefixes.count {
                        log("Storage download done!")
                        self.processKeys(keys: reports, progress: Progress(), callback: callback)
                    }
                }
            }
        }
    }

    func processKeys(keys: [ExposureDiagnosisKey], progress: Progress, callback: @escaping DetectCallback) {
        log("archiveDiagnosisKeys")
        archiveDiagnosisKeys(keys: keys) { result in
            switch result {
            case .success(let URLs):
                log("getExposureConfiguration")
                getExposureConfiguration { result in
                    switch result {
                    case let .success(configuration):
                        log("detectExposures")
                        self.manager.detectExposures(configuration: configuration, diagnosisKeyURLs: URLs) { summary, error in
                            if let error = error {
                                progress.cancel()
                                self.detectingExposures = false
                                callback(.failure(error))
                                return
                            } else if let summary = summary {
                                log("Exposure summary \(summary)")
                                let userExplanation = NSLocalizedString("Bylo detekovano nakazeni!", comment: "User notification")
                                log("getExposureInfo")
                                self.manager.getExposureInfo(summary: summary, userExplanation: userExplanation) { exposures, error in
                                    if let error = error {
                                        progress.cancel()
                                        self.detectingExposures = false
                                        callback(.failure(error))
                                        return
                                    }

                                    log("Exposures \(exposures ?? [])")
                                    
                                    let newExposures = (exposures ?? []).map { exposure in
                                        Exposure(
                                            date: exposure.date,
                                            duration: exposure.duration,
                                            totalRiskScore: exposure.totalRiskScore,
                                            transmissionRiskLevel: exposure.transmissionRiskLevel
                                        )
                                    }
                                    progress.completedUnitCount = progress.totalUnitCount
                                    self.detectingExposures = false
                                    callback(.success((newExposures)))
                                }
                            } else {
                                progress.cancel()
                                self.detectingExposures = false
                                callback(.failure(ExposureError.noData))
                            }
                        }

                    case let .failure(error):
                        progress.cancel()
                        self.detectingExposures = false
                        callback(.failure(error))
                    }
                }
            case .failure(let error):
                progress.cancel()
                self.detectingExposures = false
                callback(.failure(error))
            }
        }
    }

    func getExposureConfiguration(completion: (Result<ENExposureConfiguration, Error>) -> Void) {
        let dataFromServer = """
        {"minimumRiskScore":0,
        "attenuationDurationThresholds":[50, 70],
        "attenuationLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
        "daysSinceLastExposureLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
        "durationLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
        "transmissionRiskLevelValues":[1, 2, 3, 4, 5, 6, 7, 8]}
        """.data(using: .utf8)!

        do {
            let codableExposureConfiguration = try JSONDecoder().decode(ExposureConfiguration.self, from: dataFromServer)
            let exposureConfiguration = ENExposureConfiguration()
            exposureConfiguration.minimumRiskScore = codableExposureConfiguration.minimumRiskScore
            exposureConfiguration.attenuationLevelValues = codableExposureConfiguration.attenuationLevelValues as [NSNumber]
            exposureConfiguration.daysSinceLastExposureLevelValues = codableExposureConfiguration.daysSinceLastExposureLevelValues as [NSNumber]
            exposureConfiguration.durationLevelValues = codableExposureConfiguration.durationLevelValues as [NSNumber]
            exposureConfiguration.transmissionRiskLevelValues = codableExposureConfiguration.transmissionRiskLevelValues as [NSNumber]
            exposureConfiguration.metadata = ["attenuationDurationThresholds": codableExposureConfiguration.attenuationDurationThresholds]
            completion(.success(exposureConfiguration))
        } catch {
            completion(.failure(error))
        }
    }

    func resetAll(callback: Callback?) {

    }

}
