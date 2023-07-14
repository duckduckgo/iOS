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
import DesignResourcesKit

#if APP_TRACKING_PROTECTION

struct AppTPToggleView: View {
    
    @ObservedObject var viewModel: AppTPToggleViewModel
    
    func setup() async {
        await viewModel.refreshManager()
    }
    
    var body: some View {
        Toggle(isOn: $viewModel.isOn, label: {
            HStack {
                Text(UserText.appTPNavTitle)
                    .daxBodyRegular()
                    .foregroundColor(Color.fontColor)

                Spacer()
                
                if viewModel.isLoading() {
                    SwiftUI.ProgressView()
                }
            }
        })
        .toggleStyle(SwitchToggleStyle(tint: Color.toggleTint))
        .disabled(viewModel.isLoading())
        .onTapGesture {
            viewModel.connectFirewall.toggle()
        }
        .onChange(of: viewModel.connectFirewall) { _ in
            Task {
                await viewModel.changeFirewallStatus()
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
    enum Size {
        static let rowHeight: CGFloat = 44
    }
}

private extension Color {
    static let toggleTint = Color(designSystemColor: .accent)
    static let fontColor = Color("AppTPDomainColor")
}

#endif
