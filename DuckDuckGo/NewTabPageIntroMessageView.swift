//
//  NewTabPageIntroMessageView.swift
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
import DesignResourcesKit

struct NewTabPageIntroMessageView: View {

    var onClose: (() -> Void)?

    var body: some View {
        VStack {
            VStack(spacing: Metrics.itemSpacing) {
                HStack {
                    Text(UserText.newTabPageIntroMessageTitle)
                        .daxHeadline()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(designSystemColor: .textPrimary))
                        .frame(maxWidth: .infinity, alignment: .top)
                }
                .padding(.horizontal, Metrics.titlePadding) // Prevent showing header underneath close button

                Text(UserText.newTabPageIntroMessageBody)
                    .foregroundStyle(Color(designSystemColor: .textPrimary))
                    .daxBodyRegular()
                    .multilineTextAlignment(.center)
            }
            .padding(Metrics.padding)
            .overlay(alignment: .topTrailing) {
                Button {
                    onClose?()
                } label: {
                    Image(.close24)
                }
                .frame(alignment: .topTrailing)
                .foregroundStyle(Color(designSystemColor: .icons))
            }
        }
        .padding(Metrics.padding)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(designSystemColor: .surface))
        .cornerRadius(Metrics.cornerRadius)
        .shadow(color: .shade(0.1), radius: 2, x: 0, y: 1)
    }

    private enum Metrics {
        static let padding = 8.0
        static let itemSpacing = 6.0
        static let cornerRadius = 8.0
        static let titlePadding = 20.0
    }
}

#Preview {
    VStack {
        NewTabPageIntroMessageView().padding(16)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(designSystemColor: .background))
}
