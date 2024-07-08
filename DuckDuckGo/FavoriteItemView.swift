//
//  FavoriteItemView.swift
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

import DesignResourcesKit
import SwiftUI

struct FavoriteItemView: View {
    let favicon: Image?
    let name: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(designSystemColor: .surface))
                    .shadow(color: .shade(0.12), radius: 0.5, y: 1)
                    .aspectRatio(1, contentMode: .fit)
                
                FavoriteIconView(favicon: favicon)

            }
            
            Text(name)
                .daxCaption()
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(designSystemColor: .textPrimary))
                .frame(maxWidth: .infinity, alignment: .top)
        }
    }
}

private struct FavoriteIconView: View {
    let favicon: Image?

    var body: some View {
        if let favicon {
            favicon
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
        }
    }
}

#Preview {
    HStack(alignment: .top) {
        FavoriteItemView(favicon: nil, name: "Text").frame(width: 64)
        FavoriteItemView(favicon: nil, name: "Lorem Ipsum is simply dummy text of the printing and typesetting industry").frame(width: 64)
    }
}
