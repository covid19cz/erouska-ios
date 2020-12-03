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
import FirebaseCrashlytics
import Alamofire
import Zip
import CryptoKit

protocol ReportServicing: AnyObject {

    func updateConfiguration(_ configuration: ServerConfiguration)

    func calculateHmacKey(keys: [ExposureDiagnosisKey], secret: Data) throws -> String

    typealias UploadKeysCallback = (Result<Bool, Error>) -> Void

    var isUploading: Bool { get }
    func uploadKeys(keys: [ExposureDiagnosisKey], verificationPayload: String, hmacSecret: Data, callback: @escaping UploadKeysCallback)

    typealias DownloadKeysCallback = (Result<ReportKeys, Error>) -> Void

    var isDownloading: Bool { get }
    func downloadKeys(lastProcessedFileName: String?, callback: @escaping DownloadKeysCallback) -> Progress

}

final class ReportService: ReportServicing {

    private var healthAuthority: String

    private var uploadURL: URL

    private var downloadBaseURL: URL
    private var downloadDestinationURL: URL {
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsURL = directoryURLs.first else {
            fatalError("No documents directory!")
        }
        return documentsURL
    }
    private var downloadIndex: String

    init(configuration: ServerConfiguration) {
        healthAuthority = configuration.healthAuthority
        uploadURL = configuration.uploadURL
        downloadBaseURL = configuration.downloadsURL
        downloadIndex = configuration.downloadIndexName
    }

    func updateConfiguration(_ configuration: ServerConfiguration) {
        healthAuthority = configuration.healthAuthority
        uploadURL = configuration.uploadURL
        downloadBaseURL = configuration.downloadsURL
        downloadIndex = configuration.downloadIndexName
    }

    func calculateHmacKey(keys: [ExposureDiagnosisKey], secret: Data) throws -> String {
        // Sort by the key.
        let sortedKeys = keys.sorted { lhs, rhs -> Bool in
            lhs.keyData.base64EncodedString() < rhs.keyData.base64EncodedString()
        }

        // Build the cleartext.
        let perKeyClearText: [String] = sortedKeys.map { key in
            [key.keyData.base64EncodedString(),
             String(key.rollingStartNumber),
             String(key.rollingPeriod),
             String(key.transmissionRiskLevel)].joined(separator: ".")
        }
        let clearText = perKeyClearText.joined(separator: ",")

        guard let clearData = clearText.data(using: .utf8) else {
            throw ReportError.stringEncodingFailure
        }

        let hmacKey = SymmetricKey(data: secret)
        let authenticationCode = HMAC<SHA256>.authenticationCode(for: clearData, using: hmacKey)
        return authenticationCode.withUnsafeBytes { bytes in
            Data(bytes)
        }.base64EncodedString()
    }

    private(set) var isUploading: Bool = false

    func uploadKeys(keys: [ExposureDiagnosisKey], verificationPayload: String, hmacSecret: Data, callback: @escaping UploadKeysCallback) {
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
                Crashlytics.crashlytics().record(error: error)
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

        let randomInt = Int.random(in: 0...100)
        let randomBase64 = Data.random(count: randomInt + 100).base64EncodedString()
        let report = Report(
            temporaryExposureKeys: keys,
            healthAuthority: healthAuthority,
            verificationPayload: verificationPayload,
            hmacKey: hmacSecret.base64EncodedString(),
            symptomOnsetInterval: nil,
            traveler: false,
            revisionToken: nil,
            padding: randomBase64
        )

        AF.request(uploadURL, method: .post, parameters: report, encoder: JSONParameterEncoder.default)
            .responseDecodable(of: ReportResult.self) { response in
                #if DEBUG
                print("Response upload")
                debugPrint(response)
                #endif

                switch response.result {
                case .success(let data):
                    if let message = data.error, let code = data.code, code != "partial_failure" {
                        reportFailure(ReportUploadError.upload(code, message))
                    } else {
                        reportSuccess()
                    }
                case .failure(let error):
                    reportFailure(error)
                }
            }
    }

    private(set) var isDownloading: Bool = false

    func downloadKeys(lastProcessedFileName: String?, callback: @escaping DownloadKeysCallback) -> Progress {
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
            Crashlytics.crashlytics().record(error: error)
        }

        func reportSuccess(_ reports: [URL], lastProcessFileName: String?) {
            log("ReportService Download done")
            isDownloading = false
            callback(.success(ReportKeys(URLs: reports, lastProcessedFileName: lastProcessFileName)))
        }

        let destinationURL = self.downloadDestinationURL
        let destination: DownloadRequest.Destination = { _, response in
            let url = destinationURL.appendingPathComponent(response.suggestedFilename ?? "Exposures.zip")
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }
        var downloads: [DownloadRequest] = []

        AF.request(downloadBaseURL.appendingPathComponent(downloadIndex), method: .get)
            .validate(statusCode: 200..<300)
            .responseString { [weak self] response in
                #if DEBUG
                print("Response index")
                debugPrint(response)
                #endif
                guard let self = self else { return }

                let dispatchGroup = DispatchGroup()
                var localURLResults: [Result<[URL], Error>] = []
                var lastRemoteURL: URL?

                switch response.result {
                case let .success(result):
                    let parsedURLs = result.split(separator: "\n").compactMap { self.downloadBaseURL.appendingPathComponent(String($0)) }
                    var remoteURLs: [URL] = []
                    for url in parsedURLs {
                        remoteURLs.append(url)
                        if url.lastPathComponent == AppSettings.lastProcessedFileName {
                            remoteURLs.removeAll()
                        }
                    }

                    lastRemoteURL = remoteURLs.last

                    for remoteURL in remoteURLs {
                        dispatchGroup.enter()

                        try? FileManager.default.removeItem(at: destinationURL.appendingPathComponent(remoteURL.lastPathComponent).deletingPathExtension())

                        let download = AF.download(remoteURL, to: destination)
                            .validate(statusCode: 200..<300)
                            .response { response in
                                #if DEBUG
                                print("Response file")
                                debugPrint(response)
                                #endif

                                switch response.result {
                                case .success(let downloadedURL):
                                    guard let downloadedURL = downloadedURL else {
                                        localURLResults.append(.failure(ReportError.noFile))
                                        break
                                    }
                                    do {
                                        let changedNames = try self.unzipDownload(downloadedURL)
                                        localURLResults.append(.success(changedNames))
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
                        switch error {
                        case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
                            reportSuccess([], lastProcessFileName: nil)
                        default:
                            reportFailure(error)
                        }
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

                    reportSuccess(localURLs, lastProcessFileName: lastRemoteURL?.lastPathComponent)
                }
            }

        return progress
    }

    private func unzipDownload(_ downloadedURL: URL) throws -> [URL] {
        let unzipDirectory = try Zip.quickUnzipFile(downloadedURL)
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: unzipDirectory,
            includingPropertiesForKeys: [], options: [.skipsHiddenFiles]
        )
        let uniqueName = UUID().uuidString
        return try fileURLs.map {
            var newURL = $0
            newURL.deleteLastPathComponent()
            newURL.appendPathComponent(uniqueName)
            newURL.appendPathExtension($0.pathExtension)
            try FileManager.default.moveItem(at: $0, to: newURL)
            return newURL
        }
    }

}
