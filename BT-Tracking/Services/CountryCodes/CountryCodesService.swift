//
//  CountryCodes.swift
//  eRouska Dev
//
//  Created by Lukáš Foldýna on 03/07/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import CoreTelephony

protocol CountryCodesServicing: class {

    typealias Callback = () -> Void

    var countryCodes: [String] { get }

    var updateCallback: Callback? { get set }

}

class CountryCodeService: CountryCodesServicing {

    private var networkInfo: CTTelephonyNetworkInfo

    private(set) var countryCodes: [String] {
        didSet {
            updateCallback?()
        }
    }

    var updateCallback: Callback?

    init() {
        networkInfo = CTTelephonyNetworkInfo()
        countryCodes = []

        networkInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = { [weak self] _ in
            self?.update()
        }
        update()
    }

    func update() {
        var codes: [String] = []
        for (_, carrier) in networkInfo.serviceSubscriberCellularProviders ?? [:] {
            guard let code = carrier.isoCountryCode ?? carrier.mobileCountryCode, !codes.contains(code) else { continue }
            codes.append(code)
        }
        self.countryCodes = codes
    }

}
