//
//  AutofillItemsEmptyView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import DuckUI

struct AutofillItemsEmptyView: View {

    var importButtonAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            Image(.passwordsAdd96X96)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 96)

            Text(UserText.autofillEmptyViewTitle)
                .daxTitle3()
                .foregroundColor(Color(designSystemColor: .textPrimary))
                .padding(.top, 16)
                .multilineTextAlignment(.center)
                .lineLimit(nil)

            Text(UserText.autofillEmptyViewSubtitle)
                .daxBodyRegular()
                .foregroundColor(Color.init(designSystemColor: .textSecondary))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .lineLimit(nil)

            Button {
                importButtonAction?()
            } label: {
                Text(UserText.autofillEmptyViewButtonTitle)
            }
            .buttonStyle(PrimaryButtonStyle(fullWidth: false))
            .padding(.top, 24)
        }
        .frame(maxWidth: 300.0)
        .padding(.top, 16)
    }
}

#Preview {
    AutofillItemsEmptyView()
}
