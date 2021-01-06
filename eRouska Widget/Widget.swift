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

struct Provider: IntentTimelineProvider {

    typealias Entry = AppStateEntry

    func placeholder(in context: Context) -> Entry {
        Entry(state: AppSettings.sharedState, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(state: AppSettings.sharedState, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = Entry(state: AppSettings.sharedState, configuration: configuration)
        let timeline = Timeline<Entry>(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct AppStateEntry: TimelineEntry {
    var date: Date
    let state: ActiveAppState
    let configuration: ConfigurationIntent

    var imageName: String {
        switch state {
        case .enabled:
            return "Active"
        case .paused:
            return "Paused"
        case .disabledBluetooth:
            return "BluetoothOff"
        case .disabledExposures:
            return "ExposuresOff"
        }
    }

    var description: String {
        switch state {
        case .enabled:
            return "eRouška je aktivní"
        case .paused:
            return "eRouška je pozastavená"
        case .disabledBluetooth:
            return "Bluetooth je vypnuté"
        case .disabledExposures:
            return "Oznámení o kontaktu s COVID-19 je vypnuté"
        }
    }

    var textColor: Color {
        switch state {
        case .enabled:
            return Color("AppEnabled")
        case .paused:
            return Color("AppPaused")
        default:
            return Color("AlertRed")
        }
    }

    var actineTitle: String {
        switch state {
        case .enabled:
            return "Pozastavit"
        case .paused:
            return "Spustit"
        case .disabledExposures, .disabledBluetooth:
            return "Aktivovat"
        }
    }

    var actionURL: URL? {
        switch state {
        case .enabled:
            return URL(string: "erouska://pause")
        case .paused:
            return URL(string: "erouska://resume")
        case .disabledExposures:
            return URL(string: "erouska")
        case .disabledBluetooth:
            return URL(string: UIApplication.openSettingsURLString)
        }
    }

    init(date: Date = Date(), state: ActiveAppState, configuration: ConfigurationIntent) {
        self.date = date
        self.state = state
        self.configuration = configuration
    }
}

struct WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Image(entry.imageName)
                .resizable()
                .frame(width: 56, height: 56, alignment: .center)

            Text(entry.description)
                .font(.caption2).fontWeight(.medium)
                .foregroundColor(entry.textColor)
                .padding(.top, 2)
                .padding(.bottom, 3)
                .padding(.horizontal, 10)
                .multilineTextAlignment(.center)

            Button(entry.actineTitle) {

            }
            .font(.subheadline)
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            .frame(minWidth: 110)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color("DasboardButton"))
            )
        }.widgetURL(entry.actionURL)
    }
}

@main
struct WidgetMain: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("eRouška")
        .description("Umožnuje aktivovat nebo deaktivovat oznámení o kontaktu s COVID-19")
    }
}

struct WidgetPreviews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: AppStateEntry(state: .paused, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
