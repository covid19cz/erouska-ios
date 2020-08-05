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
    case unknown
    case alreadyRunning
}

protocol ReportServicing: class {

    typealias UploadKeysCallback = (Result<Bool, Error>) -> Void

    var isUploading: Bool { get }
    func uploadKeys(keys: [ExposureDiagnosisKey], callback: @escaping UploadKeysCallback)

    typealias DownloadKeysCallback = (Result<[URL], Error>) -> Void

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
            regions: ["CZ"],
            appPackageName: Bundle.main.bundleIdentifier ?? "iOS",
            verificationPayload: "",
            hmackey: "",
            symptomOnsetInterval: 0,
            revisionToken: "",
            padding: randomBase64,
            platform: "ios"
        )

        AF.request("https://exposure-i5jzq6zlxq-ew.a.run.app/v1/publish", method: .post, parameters: report, encoder: JSONParameterEncoder.default)
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

    func downloadKeys(callback: @escaping DownloadKeysCallback) {
        isDownloading = true

        func reportFailure(_ error: Error) {
            log("ReportService Download error: \(error)")
            DispatchQueue.main.async {
                self.isDownloading = false
                callback(.failure(error))
            }
        }

        func reportSuccess(_ reports: [URL]) {
            log("ReportService Download done")
            DispatchQueue.main.async {
                self.isDownloading = false
                callback(.success(reports))
            }
        }

        let baseURL = "https://storage.googleapis.com/exposure-notification-export-dngya/"
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)

        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsURL = directoryURLs.first else {
            reportFailure(ReportError.unknown)
            return
        }

        AF.request(baseURL + "/index.txt", method: .get)
            .validate(statusCode: 200..<300)
            .responseString { response in
            switch response.result {
            case .success(let result):
                debugPrint("Response: \(response)")
                let URLs = result.split(separator: "\n").compactMap { URL(string: baseURL + String($0)) }
                for URL in URLs {
                    try? FileManager.default.removeItem(at: documentsURL.appendingPathComponent(URL.lastPathComponent))
                    try? FileManager.default.removeItem(at: documentsURL.appendingPathComponent(URL.lastPathComponent).deletingPathExtension())

                    AF.download(URL, to: destination)
                        .validate(statusCode: 200..<300)
                        .response { response in
                            debugPrint("Response: \(response)")
                            switch response.result {
                            case .success(let downloadedURL):
                                guard let downloadedURL = downloadedURL else {
                                    reportFailure(ReportError.noData)
                                    return
                                }

                                do {
                                    let unzipDirectory = try Zip.quickUnzipFile(downloadedURL)
                                    let files = (try? FileManager.default.contentsOfDirectory(at: unzipDirectory, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])) ?? []
                                    reportSuccess(files)
                                } catch {
                                    reportFailure(error)
                                }
                            case .failure(let error):
                                reportFailure(error)
                            }
                    }
                    break
                }
            case .failure(let error):
                reportFailure(error)
            }
        }

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
