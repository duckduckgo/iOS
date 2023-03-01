//
//  SaveRecoveryKeyView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

public struct SaveRecoveryKeyView: View {

    let fakeCode = "eyJyZWNvdmVyeSI6eyJ1c2ViNjgwRDQ1QjUtNUU2RS00MzQ3jZGQkU4MEZDNEE3IiwicHJpbWFyeV9rZXkiOiJBUBUUVCQVFFQkFRRUJBUUVCBUUVCQVFFPSJ9fQ=="

    @Environment(\.presentationMode) var presentation

    let showRecoveryPDFAction: () -> Void

    public init(showRecoveryPDFAction: @escaping () -> Void) {
        self.showRecoveryPDFAction = showRecoveryPDFAction
    }

    @ViewBuilder
    func recoveryInfo() -> some View {
        ZStack {
            VStack(spacing: 26) {
                HStack(spacing: 16) {
                    QRCodeView(string: fakeCode, size: 94, style: .dark)

                    Text(fakeCode)
                        .fontWeight(.light)
                        .lineSpacing(1.6)
                        .lineLimit(3)
                        .applyKerning(2)
                        .truncationMode(.tail)
                        .monospaceSystemFont(ofSize: 16)
                        .frame(maxWidth: .infinity)
                }

                GridWithHStackFallback {
                    Button("Save as PDF") {
                        showRecoveryPDFAction()
                    }
                    .buttonStyle(PrimaryButtonStyle(compact: true))

                    Button("Copy Key") {
                        UIPasteboard.general.string = fakeCode
                    }
                    .buttonStyle(PrimaryButtonStyle(compact: true))
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.12)))
    }

    public var body: some View {
        VStack(spacing: 0) {
            Image("SyncDownloadRecoveryCode")
                .padding(.bottom, 24)

            Text(UserText.saveRecoveryTitle)
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 28)

            Text(UserText.recoveryMessage)
                .lineLimit(nil)
                .font(.system(size: 16))
                .lineSpacing(1.32)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)

            recoveryInfo()

            Spacer()

            Button {
                presentation.wrappedValue.dismiss()
            } label: {
                Text(UserText.notNowButton)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.top, 56)
        .padding(.horizontal, 30)
    }

}

struct GridWithHStackFallback<Content: View>: View {

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            Grid {
                GridRow(content: content)
            }
        } else {
            HStack(content: content)
        }
    }

}
