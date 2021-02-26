//
//  FirstActivationVM.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 18/04/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation

struct FirstActivationVM {

    // MARK: - Dependencies

    typealias Dependencies = HasExposureService

    private let dependencies: Dependencies!

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    var exposureNotificationAuthorized: Bool {
        dependencies.exposure.authorizationStatus == .authorized
    }

}
