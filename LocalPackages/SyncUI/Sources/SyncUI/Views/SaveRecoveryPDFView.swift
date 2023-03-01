//
//  SaveRecoveryPDFView.swift
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

// Screen to be re-done in this merge
public struct SaveRecoveryPDFView: View {

    @Environment(\.presentationMode) var presentation

    let showRecoveryPDFAction: () -> Void

    public init(showRecoveryPDFAction: @escaping () -> Void) {
        self.showRecoveryPDFAction = showRecoveryPDFAction
    }

    public var body: some View {
        VStack {
            Image("SyncDownloadRecoveryCode")
                .padding(.bottom, 20)

            Text(UserText.saveRecoveryTitle)
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 24)

            Text(UserText.recoveryPDFMessage)
                .lineLimit(nil)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                showRecoveryPDFAction()
            } label: {
                Text(UserText.saveRecoveryButton)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {
                presentation.wrappedValue.dismiss()
            } label: {
                Text(UserText.notNowButton)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.top, 56)
        .padding(.horizontal)
    }

}
