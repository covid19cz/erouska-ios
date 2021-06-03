//
//  CurrentDataWidget.swift
//  eRouska
//
//  Created by Lukáš Foldýna on 03.06.2021.
//

import WidgetKit
import SwiftUI

struct CurrentDataEntryView : View {
    var entry: AppStateProvider.Entry

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

struct CurrentDataWidgetPreviews: PreviewProvider {
    static var previews: some View {
        CurrentDataEntryView(entry: AppStateEntry(state: .paused, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
