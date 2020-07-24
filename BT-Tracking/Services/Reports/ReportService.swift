//
//  ReportService.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 03/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification
import FirebaseStorage
import FirebaseAuth

enum ReportError: String, Error {
    case noData
    case unknown
    case alreadyRunning
}

protocol ReportServicing: class {

    typealias UploadKeysCallback = (Result<Bool, Error>) -> Void

    var isUploading: Bool { get }
    func uploadKeys(keys: [ExposureDiagnosisKey], callback: @escaping UploadKeysCallback)

    typealias DownloadKeysCallback = (Result<[ExposureDiagnosisKey], Error>) -> Void

    var isDownloading: Bool { get }
    func downloadKeys(callback: @escaping DownloadKeysCallback)

    typealias ConfigurationCallback = (Result<ENExposureConfiguration, Error>) -> Void
    func fetchExposureConfiguration(callback: @escaping ConfigurationCallback)

}

class ReportService: ReportServicing {

    private var folderPattern: String = "exposure"
    private var filePattern: String = "exposure.json"
    private var timeout: TimeInterval = 30

    private(set) var isUploading: Bool = false

    func uploadKeys(keys: [ExposureDiagnosisKey], callback: @escaping UploadKeysCallback) {
        isUploading = true
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let encoder = JSONEncoder()

        func reportFailure(_ error: Error) {
            log("ReportService Upload error: \(error)")
            isUploading = false
            callback(.failure(error))
            return
        }

        func reportSuccess() {
            log("ReportService Upload done")
            isUploading = false
            AppSettings.lastUploadDate = Date()
            callback(.success(true))
        }

        do {
            let data = try encoder.encode(keys)

            let path = "\(folderPattern)/\(Auth.auth().currentUser?.uid ?? "")/"
            let fileReference = storageReference.child("\(path)/\(filePattern)")
            let storageMetadata = StorageMetadata()
            let metadata = [
                "version": "1",
                "buid": KeychainService.BUID ?? ""
            ]
            storageMetadata.customMetadata = metadata

            fileReference.putData(data, metadata: storageMetadata) { metadata, error in
                if let error = error {
                    reportFailure(error)
                } else {
                    reportSuccess()
                }
            }
        } catch {
            reportFailure(error)
        }
    }

    private(set) var isDownloading: Bool = false

    func downloadKeys(callback: @escaping DownloadKeysCallback) {
        isDownloading = true
        let storage = Storage.storage()
        let storageReference = storage.reference()

        func reportFailure(_ error: Error) {
            log("ReportService Download error: \(error)")
            isDownloading = false
            callback(.failure(error))
        }

        func reportSuccess(_ reports: [ExposureDiagnosisKey]) {
            log("ReportService Download done")
            isDownloading = false
            callback(.success(reports))
        }

        let folderReference = storageReference.child(folderPattern)
        folderReference.listAll { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                reportFailure(error)
                return
            }

            var count = 0
            var reports: [ExposureDiagnosisKey] = []
            let decoder = JSONDecoder()

            if result.prefixes.count == 0 {
                reportFailure(ReportError.noData)
                return
            }

            for folder in result.prefixes {
                folder.child(self.filePattern).getData(maxSize: 1024 * 100) { data, error in
                    count += 1
                    if let error = error {
                        reportFailure(error)
                        return
                    }

                    let decoded = try? decoder.decode([ExposureDiagnosisKey].self, from: data ?? Data())
                    if let values = decoded {
                        reports.append(contentsOf: values)
                    }

                    if count == result.prefixes.count {
                        reportSuccess(reports)
                        return
                    }
                }
            }
        }
    }

    func fetchExposureConfiguration(callback: @escaping ConfigurationCallback) {
        let dataFromServer = """
        {
        "minimumRiskScore":0,
        "attenuationDurationThresholds":[50, 70],
        "attenuationLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
        "daysSinceLastExposureLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
        "durationLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
        "transmissionRiskLevelValues":[1, 2, 3, 4, 5, 6, 7, 8]
        }
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
            callback(.success(exposureConfiguration))
        } catch {
            callback(.failure(error))
        }
    }

}
