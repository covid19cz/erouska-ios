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

    var updateCallback: Callback?

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
        networkInfo.subscriberCellularProviderDidUpdateNotifier = { [weak self] _ in
            self?.update()
        }

        countryCodes = []
        update()
    }

    func update() {
        var codes: [String] = []
        for carrier in networkInfo.serviceSubscriberCellularProviders {
            guard !codes.contains(carrier.isoCountryCode) else { continue }
            codes.append(codes.isoCountryCode)
        }
        self.countryCodes = codes
    }

}
