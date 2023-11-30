//
//  ScanOrEnterCodeToRecoverSyncedDataView.swift
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

public struct ScanOrEnterCodeToRecoverSyncedDataView: View {

    @ObservedObject var model: ScanOrPasteCodeViewModel

    public init(model: ScanOrPasteCodeViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 10) {
                Text(UserText.scanCodeToRecoverSyncedDataExplanation)
                    .daxFootnoteRegular()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                CameraView(model: model)
                    .aspectRatio(1.0, contentMode: .fill)
            }
            .navigationTitle(UserText.scanCodeToRecoverSyncedDataTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(UserText.cancelButton, action: model.cancel)
                        .foregroundColor(Color.white)
                }
            }
            ZStack {
                Rectangle().fill(Color.black)
                VStack(alignment: .center) {
                    HStack(spacing: 4) {
                        Text(UserText.scanCodeToRecoverSyncedDataFooter)
                            .daxBodyRegular()
                            .foregroundColor(Color(designSystemColor: .textSecondary))
                        HStack(alignment: .center) {
                            NavigationLink(UserText.scanCodeToRecoverSyncedDataEnterCodeLink, destination: {
                                PasteCodeView(model: model)
                            })
                            .foregroundColor(Color(designSystemColor: .accent))
                            Image("Arrow-Circle-Right-12")
                        }
                    }
                    .padding(20)
                    Spacer()
                }
            }
        }
    }
}
