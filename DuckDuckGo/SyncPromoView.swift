//
//  SyncPromoView.swift
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
import DuckUI

struct SyncPromoView: View {

    let viewModel: SyncPromoViewModel
    @State private var isAccessibilityHidden = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                Group {
                    Image(viewModel.image)
                        .scaledToFit()
                        .accessibilityHidden(true)
                    
                    Text(viewModel.title)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity)
                        .daxHeadline()
                    Text(viewModel.subtitle)
                        .daxSubheadRegular()
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 12)

                HStack {
                    Button {
                        viewModel.dismissButtonAction?()
                    } label: {
                        Text(viewModel.secondaryButtonTitle)
                    }
                    .buttonStyle(SecondaryFillButtonStyle(compact: true, fullWidth: false))
                    .accessibilityLabel(viewModel.secondaryButtonTitle)

                    Button {
                        viewModel.primaryButtonAction?()
                    } label: {
                        Text(viewModel.primaryButtonTitle)
                    }
                    .buttonStyle(PrimaryButtonStyle(compact: true, fullWidth: false))
                    .accessibilityLabel(viewModel.primaryButtonTitle)

                }
                .padding(.top, 12)
                .padding(.horizontal, 8)
            }
            .multilineTextAlignment(.center)
            .padding(.vertical)
            .padding(.horizontal, 8)

            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.dismissButtonAction?()
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
            .accessibilityHidden(true)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(designSystemColor: .surface))
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .accessibilityHidden(isAccessibilityHidden)
        .onAppear {
            // Delay accessibility activation for maestro
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isAccessibilityHidden = false
            }
        }
    }
}

#Preview {
    SyncPromoView(viewModel: SyncPromoViewModel())
}
