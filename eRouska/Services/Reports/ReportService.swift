//
//  ReportService.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 03/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification
import FirebaseAuth
import FirebaseCrashlytics
import Alamofire
import Zip
import Crypto

protocol HasReportService {
    var reporter: ReportServicing { get }
}

protocol ReportServicing: AnyObject {

    func updateConfiguration(_ configuration: ServerConfiguration)

    func calculateHmacKey(keys: [ExposureDiagnosisKey], secret: Data) throws -> String

    typealias UploadKeysCallback = (Result<Bool, Error>) -> Void

    var isUploading: Bool { get }
    func uploadKeys(keys: [ExposureDiagnosisKey], verificationPayload: String, hmacSecret: Data, traveler: Bool,
                    consentToFederation: Bool, symptomsDate: Date?, callback: @escaping UploadKeysCallback)

    typealias ProcessedFileNames = [String: String]
    typealias DownloadKeysCallback = (ReportDownload) -> Void

    var isDownloading: Bool { get }

    @discardableResult
    func downloadKeys(exportURLs: [ReportIndex], lastProcessedFileNames: ProcessedFileNames, callback: @escaping DownloadKeysCallback) -> Progress

}

final class ReportService: ReportServicing {

    private var healthAuthority: String

    private var uploadURL: URL
    private var firebaseURL: URL

    private var downloadIndexName: String
    private var downloadDestinationURL: URL {
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsURL = directoryURLs.first else {
            fatalError("No documents directory!")
        }
        return documentsURL
    }

    private var downloadSuccess: ReportDownload.Success = [:]
    private var downloadFailure: ReportDownload.Failure = [:]
    private var lastProcessedFileNames: ProcessedFileNames = [:]

    private var defaultEFGSList: [String] = ["BE", "GR", "LT", "PT", "BG", "ES", "LU", "RO", "FR", "HU", "SI", "DK", "HR", "MT", "SK",
                                             "DE", "IT", "NL", "FI", "EE", "CY", "AT", "SE", "IE", "LV", "PL", "IS", "NO", "LI", "CH"]

    init(configuration: ServerConfiguration) {
        healthAuthority = configuration.healthAuthority
        uploadURL = configuration.uploadURL
        firebaseURL = configuration.firebaseURL
        downloadIndexName = configuration.downloadIndexName
    }

    func updateConfiguration(_ configuration: ServerConfiguration) {
        healthAuthority = configuration.healthAuthority
        uploadURL = configuration.uploadURL
        firebaseURL = configuration.firebaseURL
        downloadIndexName = configuration.downloadIndexName
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

    func uploadKeys(keys: [ExposureDiagnosisKey], verificationPayload: String, hmacSecret: Data, traveler: Bool,
                    consentToFederation: Bool, symptomsDate: Date?, callback: @escaping UploadKeysCallback) {
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

        var symptomOnsetInterval: Int?
        if let timeInterval = symptomsDate?.timeIntervalSince1970 {
            symptomOnsetInterval = Int(timeInterval / 600)
        }

        let report = Report(
            temporaryExposureKeys: keys,
            healthAuthority: healthAuthority,
            verificationPayload: verificationPayload,
            hmacKey: hmacSecret.base64EncodedString(),
            symptomOnsetInterval: symptomOnsetInterval,
            traveler: traveler,
            revisionToken: nil,
            padding: randomBase64,
            visitedCountries: traveler ? defaultEFGSList : [],
            reportType: .confirmedTest,
            consentToFederation: consentToFederation
        )

        AF.request(firebaseURL.appendingPathComponent("PublishKeys"), method: .post, parameters: report, encoder: JSONParameterEncoder.default)
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

    private func reportDownloadFailure(country code: String, error: ReportError) {
        log("ReportService Download for country \(code), error: \(error)")
        downloadFailure[code] = error
        Crashlytics.crashlytics().record(error: error)
    }

    private func reportSuccess(country code: String, reports: [URL], lastProcessFileName: String?) {
        log("ReportService Download done for country \(code)")
        downloadSuccess[code] = ReportKeys(URLs: reports, lastProcessedFileName: lastProcessFileName)
    }

    func downloadKeys(exportURLs: [ReportIndex], lastProcessedFileNames: ProcessedFileNames, callback: @escaping DownloadKeysCallback) -> Progress {
        let progress = Progress()

        guard !isDownloading else {
            callback(ReportDownload(failure: .alreadyRunning))
            return progress
        }
        self.isDownloading = true
        self.downloadSuccess = [:]
        self.downloadFailure = [:]
        self.lastProcessedFileNames = lastProcessedFileNames

        let dispatchGroup = DispatchGroup()
        exportURLs.forEach { index in
            guard let url = URL(string: index.url) else { return }
            self.downloadIndex(country: index.country, downloadURL: url, dispatchGroup: dispatchGroup, progress: progress, callback: callback)
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            callback(ReportDownload(success: self.downloadSuccess, failures: self.downloadFailure))
            self.isDownloading = false

            log("ReportService Download all done")
        }

        return progress
    }

    private func downloadIndex(country code: String, downloadURL: URL, dispatchGroup: DispatchGroup,
                               progress: Progress, callback: @escaping DownloadKeysCallback) {
        dispatchGroup.enter()

        let destinationURL = self.downloadDestinationURL.appendingPathComponent(code)
        var downloads: [DownloadRequest] = []

        AF.request(downloadURL, method: .get)
            .validate(statusCode: 200..<300)
            .responseString { [weak self] response in
                #if DEBUG
                print("Response index")
                debugPrint(response)
                #endif
                guard let self = self else { return }

                let downloadDispatchGroup = DispatchGroup()
                var localURLResults: [Result<[URL], ReportError>] = []
                var lastRemoteURL: URL?

                switch response.result {
                case let .success(result):
                    let remoteURLs = self.parseIndexFile(result, downloadURL: downloadURL, country: code)
                    lastRemoteURL = remoteURLs.last

                    // remove old files
                    try? FileManager.default.removeItem(at: destinationURL)

                    for remoteURL in remoteURLs {
                        downloadDispatchGroup.enter()

                        let keyFileName = remoteURL.deletingPathExtension().lastPathComponent
                        let destination: DownloadRequest.Destination = { _, response in
                            let url = destinationURL.appendingPathComponent(keyFileName).appendingPathComponent(response.suggestedFilename ?? "Exposures.zip")
                            return (url, [.removePreviousFile, .createIntermediateDirectories])
                        }

                        let download = self.downloadKeyFile(destination: destination, remote: remoteURL, callback: { result in
                            localURLResults.append(result)

                            if progress.isCancelled {
                                downloads.forEach { $0.cancel() }
                            }
                            downloadDispatchGroup.leave()
                        })
                        progress.addChild(download.downloadProgress, withPendingUnitCount: 1)
                        downloads.append(download)
                    }
                case let .failure(error):
                    switch error {
                    case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
                        localURLResults.append(.success([]))
                    default:
                        localURLResults.append(.failure(.responseError(error)))
                    }
                }

                downloadDispatchGroup.notify(queue: .main) {
                    if progress.isCancelled {
                        self.downloadFailure[code] = .cancelled
                        dispatchGroup.leave()
                        return
                    }

                    var haveError: Bool = false
                    var localURLs: [URL] = []
                    for result in localURLResults {
                        switch result {
                        case let .success(URLs):
                            localURLs.append(contentsOf: URLs)
                        case let .failure(error):
                            haveError = true
                            self.downloadFailure[code] = error
                        }
                    }

                    if !haveError {
                        self.downloadSuccess[code] = ReportKeys(URLs: localURLs, lastProcessedFileName: lastRemoteURL?.lastPathComponent)
                    }
                    dispatchGroup.leave()
                }
            }

    }

    private func parseIndexFile(_ index: String, downloadURL: URL, country code: String) -> [URL] {
        var baseURL = downloadURL
        baseURL.deleteLastPathComponent()
        let parsedURLs: [URL]
        if baseURL.absoluteString.hasSuffix("//") {
            var url = baseURL.absoluteString
            url.removeLast()
            parsedURLs = index.split(separator: "\n").compactMap { URL(string: url + String($0)) ?? baseURL }
        } else {
            baseURL.deleteLastPathComponent()
            parsedURLs = index.split(separator: "\n").compactMap { baseURL.appendingPathComponent(String($0)) }
        }
        var remoteURLs: [URL] = []
        for url in parsedURLs {
            remoteURLs.append(url)
            if url.lastPathComponent == self.lastProcessedFileNames[code] {
                remoteURLs.removeAll()
            }
        }
        return remoteURLs
    }

    private typealias DownloadFileCallback = (Result<[URL], ReportError>) -> Void

    private func downloadKeyFile(destination: @escaping DownloadRequest.Destination, remote: URL, callback: @escaping DownloadFileCallback) -> DownloadRequest {
        return AF.download(remote, to: destination)
            .validate(statusCode: 200..<300)
            .response { response in
                #if DEBUG
                print("Response file")
                debugPrint(response)
                #endif

                switch response.result {
                case .success(let downloadedURL):
                    guard let downloadedURL = downloadedURL else {
                        callback(.failure(.noFile))
                        break
                    }
                    do {
                        let changedNames = try self.unzipDownload(downloadedURL)
                        callback(.success(changedNames))
                    } catch {
                        callback(.failure(.generalError(error)))
                    }
                case .failure(let error):
                    callback(.failure(.responseError(error)))
                }
            }
    }

    private func unzipDownload(_ downloadedURL: URL) throws -> [URL] {
        let baseURL = downloadedURL.deletingLastPathComponent()
        let unzipDirectory = try Zip.quickUnzipFile(downloadedURL, toURL: baseURL)
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: unzipDirectory,
            includingPropertiesForKeys: [], options: [.skipsHiddenFiles]
        )
        let uniqueName = UUID().uuidString
        return try fileURLs.map {
            let newURL = baseURL.appendingPathComponent(uniqueName + "." + $0.pathExtension)
            try FileManager.default.moveItem(at: $0, to: newURL)
            return newURL
        }
    }

}

extension Zip {

    class func quickUnzipFile(_ path: URL, toURL: URL) throws -> URL {
        let fileExtension = path.pathExtension
        let fileName = path.lastPathComponent
        let directoryName = fileName.replacingOccurrences(of: ".\(fileExtension)", with: "")
        do {
            let destinationUrl = toURL.appendingPathComponent(directoryName, isDirectory: true)
            try self.unzipFile(path, destination: destinationUrl, overwrite: true, password: nil, progress: nil)
            return destinationUrl
        } catch {
            throw ZipError.unzipFail
        }
    }

}
