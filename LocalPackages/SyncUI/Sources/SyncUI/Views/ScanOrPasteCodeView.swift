//
//  ScanOrPasteCodeView.swift
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
import DesignResourcesKit

public struct ScanOrSeeCode: View {
    @ObservedObject var model: ScanOrPasteCodeViewModel
    @State var qrCodeModel = ShowQRCodeViewModel()

    @State private var isShareSheetPresented: Bool = false

    public init(model: ScanOrPasteCodeViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 10) {
                titleView()
                CameraView(model: model)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(UserText.cancelButton, action: model.cancel)
                        .foregroundColor(Color.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(UserText.scanOrSeeCodeManuallyEnterCodeLink, destination: {
                        PasteCodeView(model: model)
                    })
                    .foregroundColor(Color(designSystemColor: .accent))
                }
            }
            qrCodeView()
        }
    }

    @ViewBuilder
    func titleView() -> some View {
        VStack(spacing: 10) {
            Text(UserText.scanOrSeeCodeTitle)
                .daxTitle2()
            instructionsText()
                .daxFootnoteRegular()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.top, 10)
    }

    func instructionsText() -> some View {
        if #available(iOS 15.0, *) {
            return Text(instructionsString)
        } else {
            return Text(UserText.scanOrSeeCodeInstruction)
        }
    }

    @available(iOS 15, *)
    var instructionsString: AttributedString {
        let baseString = UserText.scanOrSeeCodeInstructionAttributed(syncMenuPath: UserText.syncMenuPath)
        var instructions = AttributedString(baseString)
        if let range = instructions.range(of: UserText.syncMenuPath) {
            instructions[range].font = .boldSystemFont(ofSize: 13)
        }
        return instructions
    }


    @ViewBuilder
    func qrCodeView() -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 20) {
                QRCodeView(string: qrCodeModel.code ?? "", size: 120)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(UserText.scanOrSeeCodeScanCodeInstructionsTitle)
                            .daxBodyBold()
                            .fixedSize()
                        Spacer()
                        Image("SyncDeviceType_phone")
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(designSystemColor: .lines))
                            )
                    }
                    Text(UserText.scanOrSeeCodeScanCodeInstructionsBody)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(designSystemColor: .panel))
            )
            .padding(20)
            HStack {
                Text(UserText.scanOrSeeCodeFooter)
                HStack(alignment: .center) {
                    Text(UserText.scanOrSeeCodeShareCodeLink)
                        .foregroundColor(Color(designSystemColor: .accent))
                        .onTapGesture {
                            model.showShareCodeSheet()
                        }
                    Image("Arrow-Circle-Right-12")
                }
            }
        }
        .padding(.bottom, 40)
        .onAppear {
            if let recoveryCode = model.recoveryCode {
                self.qrCodeModel.code = recoveryCode
            } else {
                self.qrCodeModel = model.startConnectMode()
            }
        }
    }
}
