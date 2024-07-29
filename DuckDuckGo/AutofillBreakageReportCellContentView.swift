//
//  AutofillBreakageReportCellContentView.swift
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

struct AutofillBreakageReportCellContentView: View {

    var onReport: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(.alertRecolorable16)
                Text(UserText.autofillSettingsReportNotWorkingTitle)
                    .fontWeight(.semibold)
                    .font(.callout)
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                Spacer()
            }

            Text(UserText.autofillSettingsReportNotWorkingSubtitle)
                .padding(.trailing, 12.0)
                .daxBodyRegular()
                .foregroundColor(Color(designSystemColor: .textPrimary))

            Divider()
                .foregroundColor(Color(designSystemColor: .lines)).opacity(0.6)

                Button {
                    onReport()
                } label: {
                    HStack {
                        Text(UserText.autofillSettingsReportNotWorkingButtonTitle)
                            .daxBodyRegular()
                            .foregroundColor(Color(designSystemColor: .accent))
                        Spacer()
                    }
                }
                .padding(.vertical, 4)
        }
        .padding(.leading, 16.0)
        .padding(.vertical, 8.0)
    }
}

#Preview {
    AutofillBreakageReportCellContentView(onReport: {})
}
