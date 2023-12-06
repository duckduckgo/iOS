//
//  RecoverSyncedDataView.swift
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

public struct RecoverSyncedDataView: View {

    @ObservedObject public var model: SyncSettingsViewModel
    var onCancel: () -> Void

    public init(model: SyncSettingsViewModel, onCancel: @escaping () -> Void) {
        self.model = model
        self.onCancel = onCancel
    }

    public var body: some View {
        UnderflowContainer {
            VStack(spacing: 0) {
                HStack {
                    Button(action: onCancel, label: {
                        Text(UserText.cancelButton)
                            .foregroundColor(.primary)
                    })
                    Spacer()
                }
                .frame(height: 56)
                Image("Sync-Recover-128")
                    .padding(20)

                Text(UserText.recoverSyncedDataTitle)
                    .daxTitle1()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)

                Text(UserText.recoverSyncedDataDescription)
                        .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        } foregroundContent: {
            Button {
                model.recoverSyncDataPressed()
            } label: {
                Text(UserText.recoverSyncedDataButton)
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 360)
            .padding(.horizontal, 30)
        }
    }
}
