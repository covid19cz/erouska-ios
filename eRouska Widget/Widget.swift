//
//  eRouska_Widget.swift
//  eRouska Widget
//
//  Created by Lukáš Foldýna on 05.01.2021.
//  Copyright © 2021 Covid19CZ. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct WidgetMain: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: AppStateProvider()) { entry in
            AppStateEntryView(entry: entry)
        }
        .configurationDisplayName("eRouška")
        .description("Umožnuje aktivovat nebo deaktivovat oznámení o kontaktu s COVID-19")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
