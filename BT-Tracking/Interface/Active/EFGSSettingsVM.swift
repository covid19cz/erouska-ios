//
//  EFGSSettingsVM.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 21.11.2020.
//

import Foundation

final class EFGSSettingsVM {

    let efgsCountries = RemoteValues.efgsCountries

    func setIsPermissionGranted(_ isGranted: Bool) {
        AppSettings.efgsEnabled = isGranted
    }

}
