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

struct Provider: TimelineProvider {

    typealias Entry = SimpleEntry

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date(),
                               displayTitle: "displayTitle",
                               url: URL(string: "https://example.com")!,
                               image: UIImage(systemName: "safari")!,
                               placeholder: true))
    }

    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(),
                           displayTitle: "displayTitle",
                           url: URL(string: "https://example.com")!,
                           image: UIImage(systemName: "safari")!,
                           placeholder: true)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // First one is always a place holder so that iOS doesn't redact our widget
        let  entries = [
            SimpleEntry(date: Date(),
                        displayTitle: "displayTitle",
                        url: URL(string: "https://example.com")!,
                        image: UIImage(systemName: "safari")!,
                        placeholder: true)
        ]

        // TODO load favorites

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

}

struct SimpleEntry: TimelineEntry {

    let date: Date
    let displayTitle: String
    let url: URL
    let image: UIImage
    let placeholder: Bool

}

struct WidgetsEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack{
            Image(uiImage: entry.image)
            Text(entry.displayTitle)
        }
        .widgetURL(URL(string: "ddgNewSearch://"))
        .cornerRadius(3.0)
    }
}

struct SearchWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Rectangle().fill(Color("WidgetBackgroundColor"))

            VStack(alignment: .center, spacing: 15) {

                Image("WidgetDaxLogo")
                    .resizable()
                    .frame(width: 46, height: 46, alignment: .center)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color("WidgetSearchFieldColor"))
                        .frame(width: 123, height: 46)

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
            return SearchWidgetView(entry: entry).widgetURL(URL(string: AppDeepLinks.newSearch))
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
