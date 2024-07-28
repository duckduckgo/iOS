//
//  FavoritesTooltip.swift
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

struct FavoritesTooltip: View {
    var body: some View {
        Group {
            Text(.init("\(UserText.newTabPageTooltipBody)"))
                .daxBodyRegular()
                .foregroundStyle(Color(designSystemColor: .textPrimary))
                .padding(16)
                .frame(maxWidth: 300)
        }
        .background(Color(designSystemColor: .surface))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background(alignment: .topTrailing) {
            Triangle()
                .fill(Color(designSystemColor: .surface))
                .frame(width: 16, height: 8)
                .offset(x: -8, y: -8)
        }
        .shadow(color: .shade(0.1), radius: 2, y: 2)
        .shadow(color: .shade(0.08), radius: 1.5, y: 0)
        .padding(.horizontal, 8)
    }
}

#Preview {
    FavoritesTooltip()
}
