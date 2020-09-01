//
//  WidgetViews.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 01/09/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import WidgetKit
import SwiftUI
// import Core

struct FavoriteView: View {

    var favorite: Favorite?
    var placeholder: Bool

    var body: some View {

        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.widgetFavoritesBackground)
                .isHidden(!placeholder)

            if let favorite = favorite, !placeholder {

                Link(destination: favorite.url) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.widgetFavoritesBackground)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)

                    if let image = favorite.favicon {

                        Image(uiImage: image)
                            .scaleDown(image.size.width > 60)
                            .cornerRadius(10)
                            // .frame(maxWidth: 60, maxHeight: 60)

                    } else {
                        Text(favorite.domain.first?.uppercased() ?? "")
                            .foregroundColor(Color.widgetSearchFieldText)
                            .font(.largeTitle)
                    }
                }

            }

        }
        .frame(width: 60, height: 60, alignment: .center)

    }

}

struct LargeSearchFieldView: View {

    var placeholder: Bool

    var body: some View {
        Link(destination: URL(string: DeepLinks.newSearch)!) {
            ZStack {

                RoundedRectangle(cornerRadius: 21)
                    .fill(Color.widgetSearchFieldBackground)
                    .frame(minHeight: 46, maxHeight: 46)
                    .padding(16)

                HStack {

                    Image("WidgetDaxLogo")
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .leading)
                        .isHidden(placeholder)

                    Text("Search DuckDuckGo")
                        .foregroundColor(Color.widgetSearchFieldText)
                        .isHidden(placeholder)

                    Spacer()

                    Image("WidgetSearchLoupe")
                        .isHidden(placeholder)

                }.padding(EdgeInsets(top: 0, leading: 27, bottom: 0, trailing: 27))

            }
        }
    }

}

struct FavoritesWidgetView: View {

    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Rectangle().fill(Color.widgetBackground)

            VStack(alignment: .center, spacing: 0) {

                LargeSearchFieldView(placeholder: entry.placeholder)

                HStack(spacing: 16) {

                    ForEach(0...3, id: \.self) {
                        FavoriteView(favorite: entry.favoriteAt(index: $0), placeholder: entry.placeholder)
                    }

                }

                Spacer()

                if widgetFamily == .systemLarge {

                    HStack(spacing: 16) {

                        ForEach(4...7, id: \.self) {
                            FavoriteView(favorite: entry.favoriteAt(index: $0), placeholder: entry.placeholder)
                        }

                    }

                    Spacer()

                    HStack(spacing: 16) {

                        ForEach(8...11, id: \.self) {
                            FavoriteView(favorite: entry.favoriteAt(index: $0), placeholder: entry.placeholder)
                        }

                    }

                    Spacer()

                }

            }
        }
    }
}

struct SearchWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Rectangle().fill(Color.widgetBackground)

            VStack(alignment: .center, spacing: 15) {

                Image("WidgetDaxLogo")
                    .resizable()
                    .frame(width: 46, height: 46, alignment: .center)
                    .isHidden(entry.placeholder)

                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {

                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color.widgetSearchFieldBackground)
                        .frame(width: 123, height: 46)

                    Image("WidgetSearchLoupe")
                        .padding(.trailing)
                        .isHidden(entry.placeholder)

                }
            }
        }
    }
}


// See https://stackoverflow.com/a/59228385/73479
extension View {

    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    /// ```
    /// Text("Label")
    ///     .isHidden(true)
    /// ```
    ///
    /// Example for complete removal:
    /// ```
    /// Text("Label")
    ///     .isHidden(true, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }

}

extension Image {

    @ViewBuilder func scaleDown(_ shouldScale: Bool) -> some View {
        if shouldScale {
            self.resizable().aspectRatio(contentMode: .fit)
        } else {
            self
        }
    }

}
