//
//  NewTabPageSettingsSectionItemView.swift
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

struct NewTabPageSettingsSectionItemView: View {

    let title: String
    let iconResource: ImageResource
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(iconResource)
                .foregroundColor(Color(designSystemColor: .icons))

            Toggle(isOn: $isEnabled, label: {
                Text(title)
                    .foregroundStyle(Color(designSystemColor: .textPrimary))
                    .daxBodyRegular()
            })
            .toggleStyle(SwitchToggleStyle(tint: Color(designSystemColor: .accent)))

            Divider()
        }
        .applyListRowInsets()
    }
}

private extension View {
    @ViewBuilder
    func applyListRowInsets() -> some View {
        if #available(iOS 16, *) {
            listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8))
        } else {
            listRowInsets(EdgeInsets(top: 0, leading: -24, bottom: 0, trailing: 16))
        }
    }
}

#Preview {
    @State var isEnabled: Bool = false
    return NewTabPageSettingsSectionItemView(title: "Foo", iconResource: .favorite24, isEnabled: $isEnabled).fixedSize(horizontal: false, vertical: true)
}
