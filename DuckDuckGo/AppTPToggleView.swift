//
//  AppTPToggleView.swift
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
import NetworkExtension
import os.log

struct AppTPToggleView: View {
    @Binding var vpnOn: Bool
    @State var isExternalChange = false
    @State var connectionStatus: NEVPNStatus = .disconnected
    
    @ObservedObject var viewModel: AppTPToggleViewModel
    
    func setup() async {
        await viewModel.refreshManager()
        connectionStatus = viewModel.status()
        vpnOn = connectionStatus == .connected
    }
    
    func setFirewall(_ status: Bool) async {
        // On first load of the view we sync the status of the toggle
        // to the firewall. Setting vpnOn will trigger `onChange` of the toggle
        // We use `isExternalChange` to prevent setting the firewall status multiple times
        if isExternalChange {
            isExternalChange = false
            return
        }
        
        do {
            try await viewModel.setStatus(to: status)
            // Give time to connect (0.5s)
            try await Task.sleep(nanoseconds: 5_000_000)
            await viewModel.refreshManager()
            // In the hack days I tried to animate the state change here
        } catch {
            os_log("Unable to set firewall", log: FirewallManager.apptpLog, type: .error)
        }
    }
    
    func isLoading() -> Bool {
        return viewModel.firewallStatus != .connected && viewModel.firewallStatus != .disconnected && viewModel.firewallStatus != .invalid
    }
    
    var body: some View {
        Toggle(isOn: $vpnOn, label: {
            HStack {
                Text(UserText.appTPNavTitle)

                Spacer()
                
                if isLoading() {
                    SwiftUI.ProgressView()
                }
            }
        })
        .toggleStyle(SwitchToggleStyle(tint: Color.toggleTint))
        .disabled(isLoading())
        .onChange(of: vpnOn) { value in
            Task {
                await setFirewall(value)
            }
        }
        .padding()
        .frame(height: Const.Size.rowHeight)
        .onAppear {
            Task {
                await setup()
            }
        }
    }
}

private enum Const {
    enum Font {
        static let toggleLabel = UIFont.appFont(ofSize: 16)
    }
    
    enum Size {
        static let rowHeight: CGFloat = 44
    }
}

private extension Color {
    static let toggleTint = Color("AppTPToggleColor")
}
