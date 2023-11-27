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
import DesignResourcesKit

public struct SaveRecoveryKeyView: View {

    @Environment(\.presentationMode) var presentation
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var isCopied = false

    var isCompact: Bool {
        verticalSizeClass == .compact
    }

    let model: SaveRecoveryKeyViewModel

    public init(model: SaveRecoveryKeyViewModel) {
        self.model = model
    }

    @ViewBuilder
    func recoveryInfo() -> some View {
            VStack(spacing: 26) {
                HStack(spacing: 16) {
                    QRCodeView(string: model.key, size: 64, style: .dark)

                    Text(model.key)
                        .fontWeight(.light)
                        .lineSpacing(1.6)
                        .lineLimit(3)
                        .applyKerning(2)
                        .truncationMode(.tail)
                        .monospaceSystemFont(ofSize: 16)
                        .frame(maxWidth: .infinity)
                }
                codeButtons()
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.black.opacity(0.03)))
    }

    @ViewBuilder
    func codeButtons() -> some View {
        VStack(spacing: isCompact ? 4 : 8) {
            Button(UserText.saveRecoveryCodeSaveAsPdfButton) {
                model.showRecoveryPDFAction()
            }
            .buttonStyle(SecondaryButtonStyle(compact: isCompact))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.5)
                .stroke(.blue, lineWidth: 1)
                )

            Button(UserText.saveRecoveryCodeCopyCodeButton) {
                model.copyKey()
                isCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isCopied = false
                }
            }
            .buttonStyle(SecondaryButtonStyle(compact: isCompact))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.5)
                    .stroke(.blue, lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    func nextButton() -> some View {
        Button {
            presentation.wrappedValue.dismiss()
            model.onDismiss()
        } label: {
            Text(UserText.nextButton)
        }
        .buttonStyle(PrimaryButtonStyle(compact: isCompact))
        .overlay(
            isCopied ?
            codeCopiedToast()
            : nil
        )
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    func mainContent() -> some View {
        VStack(spacing: 0) {
            Image("SyncDownloadRecoveryCode")
                .padding(.bottom, 24)

            Text(UserText.saveRecoveryCodeSheetTitle)
                .daxTitle1()
                .padding(.bottom, 28)

            Text(UserText.saveRecoveryCodeSheetDescription)
                .lineLimit(nil)
                .daxBodyRegular()
                .lineSpacing(1.32)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)

            recoveryInfo()
                .padding(.bottom, 20)
            Text(UserText.saveRecoveryCodeSheetFooter)
                .daxCaption()
                .multilineTextAlignment(.center)
                .foregroundColor(.primary.opacity(0.6))
        }
        .padding(.top, isCompact ? 0 : 56)
        .padding(.horizontal, 30)
    }

    @ViewBuilder
    func codeCopiedToast() -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black)
                .frame(height: 45)
            Text(UserText.saveRecoveryCodeSaveCodeCopiedToast)
                .foregroundColor(.white)
                .padding()

        }
        .padding(.bottom, 50)
    }


    public var body: some View {
        UnderflowContainer {
            mainContent()
        } foregroundContent: {
            nextButton()
        }
    }

}
