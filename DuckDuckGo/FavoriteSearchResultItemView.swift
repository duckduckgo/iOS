//
//  FavoriteSearchResultItemView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import DuckUI
import LinkPresentation

struct FavoriteSearchResultItemView: View {
    let result: WebPageSearchResultValue
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            if let image = FaviconsHelper.createFakeFavicon(forDomain: result.url.absoluteString) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
            }

            VStack(alignment: .leading) {
                Text(verbatim: result.name)
                    .daxBodyRegular()
                    .multilineTextAlignment(.leading)
                Text(verbatim: result.displayUrl)
                    .daxFootnoteSemibold()
                    .multilineTextAlignment(.leading)
                if let host = result.url.host {
                    Text(verbatim: host)
                        .daxFootnoteRegular()
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()

            selectedImage
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 16)
                .foregroundColor(Color(designSystemColor: .accent))
                .padding(4)
                .background {
                    Circle().fill(Color(designSystemColor: .background))
                }
        }
    }

    private var selectedImage: Image {
        isSelected ? Image(.check24) : Image(.add24)
    }
}

#Preview {
    List {
        FavoriteSearchResultItemView(result: WebPageSearchResultValue(id: "foo", name: "bar", displayUrl: "foobar", url: URL(string: "https://foobar.url.com")!), isSelected: true)
        FavoriteSearchResultItemView(result: WebPageSearchResultValue(id: "foo", name: "bar", displayUrl: "foobar", url: URL(string: "https://foobar.url.com")!), isSelected: false)
    }
}
