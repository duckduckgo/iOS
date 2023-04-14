//
//  AppTPTrackerDetailView.swift
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
import Core

struct AppTPTrackerDetailView: View {
    
    @StateObject var viewModel: AppTPTrackerDetailViewModel
    @StateObject var feedbackModel: AppTrackingProtectionFeedbackModel
    
    @State var isBreakageLinkActive: Bool = false
    @State var showReportAlert: Bool = false
    
    var body: some View {
        ZStack {
            Color.viewBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text(viewModel.trackerDomain)
                        .font(Font(uiFont: Const.Font.sectionHeader))
                        .foregroundColor(.infoText)
                        .padding(.leading, Const.Size.sectionHeaderPadding)
                    
                    Toggle(isOn: $viewModel.isOn, label: {
                        Text(UserText.appTPBlockTracker)
                            .font(Font(uiFont: Const.Font.info))
                            .foregroundColor(.infoText)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: Color.toggleTint))
                    .padding()
                    .background(Color.cellBackground)
                    .frame(height: Const.Size.standardCellHeight)
                    .cornerRadius(Const.Size.cornerRadius)
                    .onTapGesture {
                        viewModel.isBlocking.toggle()
                    }
                    
                }
                .padding()
            }
            .navigationTitle(viewModel.trackerDomain)
            .onChange(of: viewModel.isBlocking) { value in
                viewModel.changeTrackerState()
                if !value {
                    showReportAlert = true
                }
            }
            
            NavigationLink(destination: AppTPBreakageFormView(feedbackModel: feedbackModel), isActive: $isBreakageLinkActive) {
                EmptyView()
            }
        }
        .alert(isPresented: $showReportAlert) {
            Alert(title: Text(UserText.appTPReportAlertTitle),
                  message: Text(UserText.appTPReportAlertMessage),
                  primaryButton: .default(Text(UserText.appTPReportAlertConfirm)) {
                      isBreakageLinkActive = true
                  },
                  secondaryButton: .cancel(Text(UserText.appTPReportAlertCancel))
            )
        }
    }
}

private enum Const {
    enum Font {
        static let sectionHeader = UIFont.semiBoldAppFont(ofSize: 15)
        static let info = UIFont.appFont(ofSize: 16)
    }
    
    enum Size {
        static let cornerRadius: CGFloat = 12
        static let standardCellHeight: CGFloat = 44
        static let sectionHeaderPadding: CGFloat = 16
    }
}

private extension Color {
    static let infoText = Color("AppTPDomainColor")
    static let cellBackground = Color("AppTPCellBackgroundColor")
    static let viewBackground = Color("AppTPViewBackgroundColor")
    static let toggleTint = Color("AppTPToggleColor")
}
