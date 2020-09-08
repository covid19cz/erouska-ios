//
//  CurrentData.swift
//  BT-Tracking
//
//  Created by Naim Ashhab on 26/08/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import RealmSwift

final class CurrentDataRealm: Object {
    @objc dynamic var testsTotal: Int = 0
    @objc dynamic var testsIncrease: Int = 0
    @objc dynamic var confirmedCasesTotal: Int = 0
    @objc dynamic var confirmedCasesIncrease: Int = 0
    @objc dynamic var activeCasesTotal: Int = 0
    @objc dynamic var curedTotal: Int = 0
    @objc dynamic var deceasedTotal: Int = 0
    @objc dynamic var currentlyHospitalizedTotal: Int = 0

    convenience init(
        testsTotal: Int,
        testsIncrease: Int,
        confirmedCasesTotal: Int,
        confirmedCasesIncrease: Int,
        activeCasesTotal: Int,
        curedTotal: Int,
        deceasedTotal: Int,
        currentlyHospitalizedTotal: Int
    ) {
        self.init()

        self.testsTotal = testsTotal
        self.testsIncrease = testsIncrease
        self.confirmedCasesTotal = confirmedCasesTotal
        self.confirmedCasesIncrease = confirmedCasesIncrease
        self.activeCasesTotal = activeCasesTotal
        self.curedTotal = curedTotal
        self.deceasedTotal = deceasedTotal
        self.currentlyHospitalizedTotal = currentlyHospitalizedTotal
    }
}
