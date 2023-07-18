//
//  NetworkProtectionStatusView.swift
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

#if NETWORK_PROTECTION

import SwiftUI
import NetworkProtection

struct NetworkProtectionStatusView: View {
    @ObservedObject public var statusModel: NetworkProtectionStatusViewModel

    var body: some View {
        List {
            toggle()
        }
    }

    @ViewBuilder
    func toggle() -> some View {
        Section {
            HStack {
                Text("Network Protection")

                Toggle("", isOn: Binding(
                    get: { statusModel.isNetPEnabled },
                    set: statusModel.didToggleNetP(to:)
                ))
                .disabled(statusModel.shouldShowLoading)
                .toggleStyle(SwitchToggleStyle(tint: Color(designSystemColor: .accent)))
            }
            HStack {
                if let status = statusModel.statusMessage {
                    Text(status)
                        .foregroundColor(statusModel.isNetPEnabled ? .green : .red)
                }
            }
        } footer: {
            Text(UserText.netPCellDetail)
        }
    }
    }
}

struct NetworkProtectionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkProtectionStatusView()
        NetworkProtectionStatusView(statusModel: NetworkProtectionStatusViewModel())
    }
}

#endif
