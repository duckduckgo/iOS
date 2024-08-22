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
    let faviconLoader: FavoritesFaviconLoading?

    var body: some View {
        HStack(spacing: 16) {
            if let domain = result.url.host {
                FavoriteIconView(domain: domain, size: 24, faviconLoading: faviconLoader)
                    .frame(width: 24)
            }

            VStack(alignment: .leading) {
                Text(verbatim: result.name)
                    .daxBodyRegular()
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                Text(verbatim: result.displayUrl)
                    .daxFootnoteSemibold()
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    List {
        FavoriteSearchResultItemView(result: WebPageSearchResultValue(id: "foo", name: "bar", displayUrl: "foobar", url: URL(string: "https://foobar.url.com")!), faviconLoader: nil)
        FavoriteSearchResultItemView(result: WebPageSearchResultValue(id: "foo", name: "bar", displayUrl: "foobar", url: URL(string: "https://foobar.url.com")!), faviconLoader: nil)
    }
}
