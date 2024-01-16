//
//  PreparingToSyncView.swift
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


public struct PreparingToSyncView: View {

    public init() {}

    public var body: some View {
        UnderflowContainer {
            VStack(spacing: 0) {
                Image("Sync-128")
                    .padding(20)

                Text(UserText.preparingToSyncSheetTitle)
                    .daxTitle1()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)

                Text(UserText.preparingToSyncSheetDescription)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        } foregroundContent: {
            Text(UserText.preparingToSyncSheetFooter)
                .foregroundColor(Color(designSystemColor: .textSecondary))
        }
    }
}
