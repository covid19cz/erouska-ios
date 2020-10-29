//
//  Configuration.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 17/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import ExposureNotification

struct ServerConfiguration: Codable {

    // swiftlint:disable force_unwrapping
    static var development: ServerConfiguration {
        ServerConfiguration(
            minSupportedVersion: "13.5",
            showExposureForDays: 14,
            healthAuthority: "cz.covid19cz.erouska",
            uploadURL: URL(string: "https://exposure-i5jzq6zlxq-ew.a.run.app/v1/publish")!,
            downloadIndexName: "/index.txt",
            downloadsURL: URL(string: "https://storage.googleapis.com/exposure-notification-export-ejjud/")!,
            verificationURL: URL(string: "https://apiserver-eyrqoibmxa-ew.a.run.app")!,
            verificationAdminKey: "",
            verificationDeviceKey: RemoteValues.verificationServerApiKey,
            appCurentDataURL: URL(string: "https://europe-west1-daring-leaf-272223.cloudfunctions.net")!
        )
    }

    static var production: ServerConfiguration {
        ServerConfiguration(
            minSupportedVersion: "13.5",
            showExposureForDays: 14,
            healthAuthority: "cz.covid19cz.erouska",
            uploadURL: URL(string: "https://exposure-fghz64a2xa-ew.a.run.app/v1/publish")!,
            downloadIndexName: "erouska/index.txt",
            downloadsURL: URL(string: "https://storage.googleapis.com/exposure-notification-export-qhqcx/")!,
            verificationURL: URL(string: "https://apiserver-jyvw4xgota-ew.a.run.app")!,
            verificationAdminKey: "",
            verificationDeviceKey: RemoteValues.verificationServerApiKey,
            appCurentDataURL: URL(string: "https://europe-west1-daring-leaf-272223.cloudfunctions.net")!
        )
    }
    // swiftlint:enable force_unwrapping

    let minSupportedVersion: String

    let showExposureForDays: Int

    let healthAuthority: String

    let uploadURL: URL

    let downloadIndexName: String

    let downloadsURL: URL

    let verificationURL: URL

    let verificationAdminKey: String
    let verificationDeviceKey: String

    let appCurentDataURL: URL

    init(minSupportedVersion: String, showExposureForDays: Int, healthAuthority: String, uploadURL: URL,
         downloadIndexName: String, downloadsURL: URL,
         verificationURL: URL, verificationAdminKey: String, verificationDeviceKey: String,
         appCurentDataURL: URL) {
        self.minSupportedVersion = minSupportedVersion
        self.showExposureForDays = showExposureForDays
        self.healthAuthority = healthAuthority
        self.uploadURL = uploadURL
        self.downloadIndexName = downloadIndexName
        self.downloadsURL = downloadsURL
        self.verificationURL = verificationURL
        self.verificationAdminKey = verificationAdminKey
        self.verificationDeviceKey = verificationDeviceKey
        self.appCurentDataURL = appCurentDataURL
    }

}
