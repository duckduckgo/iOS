//
//  FavoriteIconView.swift
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

struct FavoriteIconView: View {
    @ObservedObject var model: FavoriteIconViewModel

    @State private var favicon: Favicon = .empty

    init(model: FavoriteIconViewModel) {
        self.model = model
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(designSystemColor: .surface))
                .shadow(color: .shade(0.12), radius: 0.5, y: 1)
                .aspectRatio(1, contentMode: .fit)

            if favicon.isEmpty {
                Text("EMPTY?!")
            }

            // STATE APPROACH
            Image(uiImage: favicon.image)
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .if(favicon.isUsingBorder) {
                    $0.padding(Constant.borderSize)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .task {
                    self.favicon = model.createFakeFavicon(size: Constant.faviconSize)
                    if let favicon = await model.loadFavicon(size: Constant.faviconSize) {
                        self.favicon = favicon
                    }
                }
            // END

            // MODEL APPROACH
//            let favicon = model.favicon
//            Image(uiImage: favicon.image)
//                .resizable()
//                .aspectRatio(1.0, contentMode: .fit)
//                .if(favicon.isUsingBorder) {
//                    $0.padding(Constant.borderSize)
//                }
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//                .task {
//                    await model.loadFavicon(size: Constant.faviconSize)
//                }
            // END
        }
    }
}

private struct Constant {
    static let faviconSize: CGFloat = 40
    static let borderSize: CGFloat = 12
}

#Preview {
    VStack(spacing: 8) {
        FavoriteIconView(model: FavoriteIconViewModel(domain: "apple.com", onFaviconMissing: nil))
        FavoriteIconView(model: FavoriteIconViewModel(domain: "duckduckgo.com", onFaviconMissing: nil))
        FavoriteIconView(model: FavoriteIconViewModel(domain: "foobar.com", onFaviconMissing: nil))
    }
}
