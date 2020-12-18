//
//  Analytics.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 10.12.2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import FirebaseAnalytics

enum Events: String {

    case tapPauseApp = "click_pause_app"
    case tapResumeApp = "click_resume_app"

    case tapTabHome = "click_tab_home"
    case tapTabNews = "click_tab_news"
    case tapTabContacts = "click_tab_contacts"
    case tapTabHelp = "click_tab_help"

    case tapNewsCurrentMeasures = "click_current_measures"

    case keyExportDownloadStarted = "key_export_download_started"
    case keyExportDownloadFinished = "key_export_download_finished"

    func logEvent() {
        Analytics.logEvent(rawValue, parameters: [:])
    }

}
