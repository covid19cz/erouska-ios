//
//  CurrentDataWidget.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 03.06.2021.
//

import WidgetKit
import SwiftUI

struct CurrentDataEntryView: View {
    var entry: AppStateProvider.Entry

    var body: some View {
        VStack {
            CurrentDataRowView(iconName: "test1", title: "Title 1", subtitle: "Subtitle 1")

            CurrentDataRowView(iconName: "test2", title: "Title 2", subtitle: "Subtitle 2")

            CurrentDataRowView(iconName: "test3", title: "Title 3", subtitle: "Subtitle 3")

            CurrentDataRowView(iconName: "test4", title: "Title 4", subtitle: "Subtitle 4")
        }.widgetURL(entry.actionURL)
    }
}

struct CurrentDataRowView: View {
    let iconName: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(iconName)
                .resizable()
                .frame(width: 25, height: 25, alignment: .center)
                .accentColor(Color("DataColor"))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote).fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption2).fontWeight(.regular)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }.padding(.horizontal, 16)
    }
}

struct CurrentDataWidgetPreviews: PreviewProvider {
    static var previews: some View {
        CurrentDataEntryView(entry: AppStateEntry(state: .paused, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
