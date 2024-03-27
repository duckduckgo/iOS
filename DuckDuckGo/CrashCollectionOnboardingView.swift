//
//  CrashCollectionOnboardingView.swift
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
import DuckUI
import DesignResourcesKit

struct CrashCollectionOnboardingView: View {

    @ObservedObject var model: CrashCollectionOnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 24) {
                Image("Breakage-128")

                Text("Send crash report?")
                    .daxTitle1()

                Text("It looks like the app has crashed. Would you like to submit crash logs to DuckDuckGo? Crash logs help DuckDuckGo diagnose issues and improve our products. No personal information is sent with crash logs.")
                    .multilineTextAlignment(.center)
                    .daxBodyRegular()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            VStack(spacing: 8) {
                Button {
                    withAnimation {
                        model.sendCrashLogs = true
                        model.onDismiss(true)
                    }
                } label: {
                    Text("Send Crash Logs")
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 360)

                Button {
                    withAnimation {
                        model.sendCrashLogs = false
                        model.onDismiss(false)
                    }
                } label: {
                    Text("Don't Send Crash Logs")
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(maxWidth: 360)
            }
            .padding(.init(top: 24, leading: 24, bottom: 0, trailing: 24))
        }
    }
}
