//
//  AppTPManageTrackersView.swift
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
import DesignResourcesKit

struct AppTPManageTrackersView: View {
    
    @StateObject var viewModel: AppTPManageTrackersViewModel
    @StateObject var feedbackModel: AppTrackingProtectionFeedbackModel
    
    @State var isBreakageLinkActive: Bool = false
    @State var showReportAlert: Bool = false
    
    let imageCache: AppTrackerImageCache
    
    func onTrackerToggled(domain: String, isBlocking: Bool) {
        viewModel.changeState(for: domain, blocking: isBlocking)
    }
    
    func restoreDefaults() {
        viewModel.resetAllowlist()
        DispatchQueue.main.async {
            ActionMessageView.present(message: UserText.appTPRestoreDefaultsToast,
                                      presentationLocation: .withoutBottomBar)
        }
    }
    
    var loadingState: some View {
        VStack {
            SwiftUI.ProgressView()
        }
        .frame(maxHeight: .infinity)
    }
    
    var body: some View {
        ZStack {
            Color.viewBackground
                .ignoresSafeArea()
            
            if viewModel.trackerList.count == 0 {
                loadingState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Section {
                            Button(action: {
                                restoreDefaults()
                            }, label: {
                                HStack {
                                    Spacer()
                                    
                                    Text(UserText.appTPRestoreDefaults)
                                        .daxBodyRegular()
                                        .foregroundColor(Color.buttonTextColor)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .frame(height: Const.Size.standardCellHeight)
                            })
                            .background(Color.cellBackground)
                            .cornerRadius(Const.Size.cornerRadius)
                            .padding(.bottom)
                        }
                        
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.trackerList, id: \.hashValue) { tracker in
                                let showDivider = tracker != viewModel.trackerList.last
                                AppTPManageTrackerCell(trackerDomain: tracker.domain,
                                                       trackerBlocked: tracker.blocking,
                                                       trackerOwner: tracker.trackerOwner,
                                                       imageCache: imageCache,
                                                       showDivider: showDivider,
                                                       onToggleTracker: onTrackerToggled(domain:isBlocking:))
                            }
                        }
                        .background(Color.cellBackground)
                        .cornerRadius(Const.Size.cornerRadius)
                    }
                    .padding()
                }
            }
            
            NavigationLink(destination: AppTPBreakageFormView(feedbackModel: feedbackModel), isActive: $isBreakageLinkActive) {
                EmptyView()
            }
        }
        .navigationTitle(UserText.appTPManageTrackers)
        .onAppear {
            Task {
                viewModel.buildTrackerList()
            }
        }
        .alert(isPresented: $showReportAlert) {
            Alert(title: Text(UserText.appTPReportAlertTitle),
                  message: Text(UserText.appTPReportAlertMessage),
                  primaryButton: .cancel(Text(UserText.appTPReportAlertConfirm)) {
                      isBreakageLinkActive = true
                      viewModel.trackerDisabled = false
                  },
                  secondaryButton: .default(Text(UserText.appTPReportAlertCancel)) {
                      viewModel.trackerDisabled = false
                  }
            )
        }
        .onChange(of: viewModel.trackerList) { _ in
            if viewModel.trackerDisabled {
                showReportAlert = true
            }
        }
    }
}

private enum Const {
    enum Size {
        static let cornerRadius: CGFloat = 12
        static let standardCellHeight: CGFloat = 44
    }
}

private extension Color {
    static let cellBackground = Color(designSystemColor: .surface)
    static let viewBackground = Color(designSystemColor: .background)
    static let buttonTextColor = Color(designSystemColor: .accent)
}
