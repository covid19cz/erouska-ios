//
//  Downloader.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 03/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

protocol DownloadServicing: class {

}

class DownloadService: DownloadServicing {

    private var filePattern: String = "/diag_keys/%s/keys_%s.pb"
    private var timeout: TimeInterval = 30

}
