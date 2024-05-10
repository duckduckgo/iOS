//
//  PasswordsSurveyView.swift
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
import Core
import DesignResourcesKit
import DuckUI

struct PasswordsSurveyView: View {

    var surveyButtonAction: (() -> Void)?
    var closeButtonAction: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Group {
                    Image(.passwordsDDG96X96)
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)

                    Text("Help us improve!")
                        .daxHeadline()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity)

                    Text("We want to make using passwords in DuckDuckGo better.")
                        .daxBodyRegular()
                        .foregroundColor(Color(designSystemColor: .textPrimary))
                        .padding(.top, 4)

                    Button {
                        surveyButtonAction?()
                    } label: {
                        HStack {
                            Text("Take Survey")
                                .daxButton()
                        }
                    }
                    .buttonStyle(SurveyButtonStyle())
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
            }
            .multilineTextAlignment(.center)
            .padding(.vertical)
            .padding(.horizontal, 8)

            closeButtonHeader
                .alignmentGuide(.top) { dimension in
                    dimension[.top]
                }
        }
        .background(RoundedRectangle(cornerRadius: 8.0)
            .fill(Color("HomeMessageBackgroundColor"))
        )
        .onFirstAppear {
            Pixel.fire(pixel: .autofillManagementScreenVisitSurveyAvailable)
        }
        .frame(maxWidth: 380)
        .padding([.horizontal, .top], 20)
        .padding(.bottom, 30)
    }

    private var closeButtonHeader: some View {
        VStack {
            HStack {
                Spacer()
                closeButton
                    .padding(0)
            }
        }
    }

    private var closeButton: some View {
        Button {
            closeButtonAction?()
        } label: {
            Image("Close-24")
                .foregroundColor(.primary)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
}

private struct SurveyButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Self.Configuration) -> some View {
        let isDark = colorScheme == .dark

        let backgroundColor =  isDark ? Color.blue30 : Color.blueBase
        let foregroundColor = isDark ? Color.black.opacity(0.84) : Color.white
        let pressedBackgroundColor = isDark ? Color.blueBase : Color.blue70

        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .frame(height: 40)
            .foregroundColor(foregroundColor)
            .background(configuration.isPressed ? pressedBackgroundColor : backgroundColor)
            .cornerRadius(8)
    }
}

#Preview("Light") {
    PasswordsSurveyView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    PasswordsSurveyView()
        .preferredColorScheme(.dark)
}
