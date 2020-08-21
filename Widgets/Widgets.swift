//
//  Widgets.swift
//  Widgets
//
//  Created by Chris Brind on 19/08/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import Core
import os

struct Provider: TimelineProvider {

    typealias Entry = SimpleEntry

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        os_log("appIconName %s", #function)
        completion(SimpleEntry(date: Date(), backgroundColorName: backgroundColorName()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        os_log("appIconName %s", #function)
        let entries = [
            SimpleEntry(date: Date(), backgroundColorName: backgroundColorName())
        ]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func backgroundColorName() -> String {
        os_log("appIconName: bookmark count %d", BookmarkUserDefaults().bookmarks.count)
        os_log("appIconName: %s", SharedSettings.shared.appIconName ?? "<nil>")

        guard let appIconName = SharedSettings.shared.appIconName else {
            return "WidgetBackgroundColor_red"
        }

        return "WidgetBackgroundColor_" + appIconName
    }

}

struct SimpleEntry: TimelineEntry {

    let date: Date
    let backgroundColorName: String

}

struct WidgetsEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack{
            Text("WidgetsEntryView")
        }
        .cornerRadius(3.0)
    }
}

struct SearchWidgetView: View {

    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Rectangle().fill(Color(entry.backgroundColorName))

            VStack(alignment: .center, spacing: 15) {

                Image("Dax")
                    .resizable()
                    .frame(width: 46, height: 46, alignment: .center)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color.white)
                        .frame(width: 123, height: 46)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0.0, y: 2.0)

                    Image("WidgetSearchLoupe")
                        .padding(.trailing)

                }
            }
        }
    }
}

struct SearchWidget: Widget {
    let kind: String = "SearchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            return SearchWidgetView(entry: entry)
                .widgetURL(URL(string: AppDeepLinks.newSearch))
        }
        .configurationDisplayName("Search")
        .description("Quickly launch a search in DuckDuckGo")
        .supportedFamilies([.systemSmall])
    }

}

struct FavoritesWidget: Widget {
    let kind: String = "FavoritesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Favorites")
        .description("Show your top favorites on your home screen")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@main
struct Widgets: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        SearchWidget()
        FavoritesWidget()
    }

}

// Previews don't work yet anyway
//struct Widgets_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetsEntryView(entry: SimpleEntry(date: Date(),
//                                            displayTitle: "Example",
//                                            url: URL(string: "https://example.com")!,
//                                            image: UIImage(systemName: "safari")!,
//                                            placeholder: true))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
