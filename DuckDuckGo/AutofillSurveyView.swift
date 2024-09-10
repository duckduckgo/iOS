//
//  AutofillSurveyView.swift
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

import Core
import DesignResourcesKit
import DuckUI
import SwiftUI

struct AutofillSurveyView: View {
    var primaryButtonAction: (() -> Void)?
    var dismissButtonAction: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Group {
                    Image(.passwordsDDG96X96)
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)

                    Text(verbatim: "Help us improve!")
                        .daxHeadline()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity)

                    Text(verbatim: "We want to make using passwords in DuckDuckGo better.")
                        .daxBodyRegular()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                        .padding(.top, 4)

                    Button {
                        primaryButtonAction?()
                    } label: {
                        HStack {
                            Text(verbatim: "Take Survey")
                                .daxButton()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(compact: true, fullWidth: false))
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
            }
            .multilineTextAlignment(.center)
            .padding(.vertical)
            .padding(.horizontal, 8)

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismissButtonAction?()
                    } label: {
                        Image(.close24)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .padding(0)
                }
            }
            .alignmentGuide(.top) { dimension in
                dimension[.top]
            }
        }
        .background(RoundedRectangle(cornerRadius: 8.0)
            .foregroundColor(Color(designSystemColor: .surface))
        )
        .padding([.horizontal, .top], 20)
        .padding(.bottom, 30)
    }

}

#Preview("Light") {
    AutofillSurveyView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    AutofillSurveyView()
        .preferredColorScheme(.dark)
}
