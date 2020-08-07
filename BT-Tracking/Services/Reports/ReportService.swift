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
import CommonCrypto
import Security
import Alamofire
import Zip

enum ReportError: String, Error {
    case noData
    case noFile
    case cancelled
    case unknown
    case alreadyRunning
}

protocol ReportServicing: class {

    var healthAuthority: String { get set }

    typealias UploadKeysCallback = (Result<Bool, Error>) -> Void

    var isUploading: Bool { get }
    func uploadKeys(keys: [ExposureDiagnosisKey], callback: @escaping UploadKeysCallback)

    typealias DownloadKeysCallback = (Result<[URL], Error>) -> Void

    var isDownloading: Bool { get }
    func downloadKeys(callback: @escaping DownloadKeysCallback) -> Progress

    typealias ConfigurationCallback = (Result<ENExposureConfiguration, Error>) -> Void
    func fetchExposureConfiguration(callback: @escaping ConfigurationCallback)

}

class ReportService: ReportServicing {

    var healthAuthority = "cz.covid19cz.erouska.dev"

    private var timeout: TimeInterval = 30

    private let uploadURL = URL(string: "https://exposure-i5jzq6zlxq-ew.a.run.app/v1/publish")!

    private let downloadBaseURL = URL(string: "https://storage.googleapis.com/exposure-notification-export-ejjud//")!
    private var downloadDestinationURL: URL {
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsURL = directoryURLs.first else {
            fatalError("No documents directory!")
        }
        return documentsURL
    }
    private let downloadIndex = "index.txt"

    private(set) var isUploading: Bool = false

    func uploadKeys(keys: [ExposureDiagnosisKey], callback: @escaping UploadKeysCallback) {
        guard !isUploading else {
            callback(.failure(ReportError.alreadyRunning))
            return
        }
        isUploading = true

        func reportFailure(_ error: Error) {
            log("ReportService Upload error: \(error)")
            DispatchQueue.main.async {
                self.isUploading = false
                callback(.failure(error))
            }
            return
        }

        func reportSuccess() {
            log("ReportService Upload done")
            DispatchQueue.main.async {
                self.isUploading = false
                AppSettings.lastUploadDate = Date()
                callback(.success(true))
            }
        }

        let randomInt = Int.random(in: 0...1000)
        let randomBase64 = Data(count: randomInt + 1000).base64EncodedString()
        let report = Report(
            temporaryExposureKeys: keys,
            healthAuthority: healthAuthority,
            revisionToken: nil,
            padding: randomBase64
        )

        AF.request(uploadURL, method: .post, parameters: report, encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ReportResult.self) { response in
            debugPrint("Response: \(response)")
            switch response.result {
            case .success:
                reportSuccess()
            case .failure(let error):
                reportFailure(error)
            }
        }
    }

    private(set) var isDownloading: Bool = false

    func downloadKeys(callback: @escaping DownloadKeysCallback) -> Progress {
        let progress = Progress()

        guard !isDownloading else {
            callback(.failure(ReportError.alreadyRunning))
            return progress
        }
        isDownloading = true

        func reportFailure(_ error: Error) {
            log("ReportService Download error: \(error)")
            isDownloading = false
            callback(.failure(error))
        }

        func reportSuccess(_ reports: [URL]) {
            log("ReportService Download done")
            isDownloading = false
            callback(.success(reports))
        }

        let destinationURL = self.downloadDestinationURL
        let destination: DownloadRequest.Destination = { temporaryURL, response in
            let url = destinationURL.appendingPathComponent(response.suggestedFilename!)
            return (url, .removePreviousFile)
        }
        var downloads: [DownloadRequest] = []

        AF.request(downloadBaseURL.appendingPathComponent(downloadIndex), method: .get)
            .validate(statusCode: 200..<300)
            .responseString { [weak self] response in
                debugPrint("Response index: \(response)")
                guard let self = self else { return }

                let dispatchGroup = DispatchGroup()
                var localURLResults: [Result<[URL], Error>] = []

                switch response.result {
                case let .success(result):
                    let remoteURLs = result.split(separator: "\n").compactMap { self.downloadBaseURL.appendingPathComponent(String($0)) }

                    for remoteURL in remoteURLs {
                        dispatchGroup.enter()

                        try? FileManager.default.removeItem(at: destinationURL.appendingPathComponent(remoteURL.lastPathComponent).deletingPathExtension())

                        let download = AF.download(remoteURL, to: destination)
                            .validate(statusCode: 200..<300)
                            .response { response in
                                debugPrint("Response file: \(response)")

                                switch response.result {
                                case .success(let downloadedURL):
                                    guard let downloadedURL = downloadedURL else {
                                        localURLResults.append(.failure(ReportError.noFile))
                                        break
                                    }
                                    do {
                                        let unzipDirectory = try Zip.quickUnzipFile(downloadedURL)
                                        let fileURLs = try FileManager.default.contentsOfDirectory(at: unzipDirectory, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
                                        localURLResults.append(.success(fileURLs))
                                    } catch {
                                        localURLResults.append(.failure(error))
                                    }
                                case .failure(let error):
                                    localURLResults.append(.failure(error))
                                }

                                if progress.isCancelled {
                                    downloads.forEach { $0.cancel() }
                                }
                                dispatchGroup.leave()
                        }
                        progress.addChild(download.downloadProgress, withPendingUnitCount: 1)
                        downloads.append(download)
                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        reportFailure(error)
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    if progress.isCancelled {
                        reportFailure(ReportError.cancelled)
                        return
                    }

                    var localURLs: [URL] = []
                    for result in localURLResults {
                        switch result {
                        case let .success(URLs):
                            localURLs.append(contentsOf: URLs)
                        case let .failure(error):
                            reportFailure(error)
                            return
                        }
                    }
                    reportSuccess(localURLs)
                }
        }

        return progress
    }

    func fetchExposureConfiguration(callback: @escaping ConfigurationCallback) {
        let dataFromServer = """
        {
        "minimumRiskScore": 0,
        "attenuationDurationThresholds": [50, 70],
        "attenuationLevelValues": [1, 2, 3, 4, 5, 6, 7, 8],
        "daysSinceLastExposureLevelValues": [1, 2, 3, 4, 5, 6, 7, 8],
        "durationLevelValues": [1, 2, 3, 4, 5, 6, 7, 8],
        "transmissionRiskLevelValues": [1, 2, 3, 4, 5, 6, 7, 8]
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
