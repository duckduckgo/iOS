//
//  AppTPActivityView.swift
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

#if APP_TRACKING_PROTECTION

struct AppTPActivityView: View {
    @ObservedObject var viewModel: AppTrackingProtectionListViewModel
    @ObservedObject var feedbackModel: AppTrackingProtectionFeedbackModel
    @ObservedObject var toggleViewModel = AppTPToggleViewModel()

    let imageCache = AppTrackerImageCache()
    
    let setNavColor: ((Bool) -> Void)?
    
    func imageForState() -> Image {
        return toggleViewModel.isOn ? Image("AppTPEmptyEnabled") : Image("AppTPEmptyDisabled")
    }
    
    func textForState() -> String {
        return toggleViewModel.isOn ? UserText.appTPEmptyEnabledInfo : UserText.appTPEmptyDisabledInfo
    }
    
    func enableAppTPFromOnboarding() {
        setNavColor?(false)
        viewModel.appTPUsed = true
        toggleViewModel.connectFirewall = true
        Task { @MainActor in
            await toggleViewModel.changeFirewallStatus()
        }
    }
    
    var emptyState: some View {
        VStack {
            imageForState()
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 96)
                .padding(.bottom)
            
            Text(textForState())
                .multilineTextAlignment(.center)
                .font(Font(uiFont: Const.Font.info))
                .foregroundColor(.infoText)
        }
        .padding()
        .padding(.top)
    }
    
    var listState: some View {
        VStack {
            ForEach(viewModel.sections, id: \.name) { section in
                Section(content: {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(section.objects as? [AppTrackerEntity] ?? []) { tracker in
                            let showDivider = tracker != (section.objects?.last as? AppTrackerEntity)
                            NavigationLink(
                                destination: AppTPTrackerDetailView(
                                    viewModel: AppTPTrackerDetailViewModel(trackerDomain: tracker.domain),
                                    feedbackModel: feedbackModel
                                )
                            ) {
                                AppTPTrackerCell(trackerDomain: tracker.domain,
                                                 trackerOwner: tracker.trackerOwner,
                                                 trackerCount: tracker.count,
                                                 trackerBlocked: tracker.blocked,
                                                 trackerTimestamp: viewModel.format(timestamp: tracker.timestamp),
                                                 trackerBucket: tracker.bucket,
                                                 debugMode: viewModel.debugModeEnabled,
                                                 imageCache: imageCache,
                                                 showDivider: showDivider)
                            }
                        }
                    }
                    .background(Color.cellBackground)
                    .cornerRadius(Const.Size.cornerRadius)
                }, header: {
                    HStack {
                        Text(viewModel.formattedDate(section.name).uppercased())
                            .font(Font(uiFont: Const.Font.sectionHeader))
                            .foregroundColor(.infoText)
                            .padding(.top)
                            .padding(.leading, Const.Size.sectionIndentation)
                            .padding(.bottom, Const.Size.sectionHeaderBottom)
                        
                        Spacer()
                    }
                })
            }
        }
    }
    
    var manageSection: some View {
        Group {
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink(destination: AppTPManageTrackersView(viewModel: AppTPManageTrackersViewModel(),
                                                                        feedbackModel: feedbackModel,
                                                                        imageCache: imageCache)) {
                        AppTPLinkButton(buttonText: UserText.appTPManageTrackers)
                    }
                    
                    Divider()
                        .padding(.leading)
                    
                    NavigationLink(destination: AppTPBreakageFormView(feedbackModel: feedbackModel)) {
                        AppTPLinkButton(buttonText: UserText.appTPReportIssueButton)
                    }
                }
                .background(Color.cellBackground)
                .cornerRadius(Const.Size.cornerRadius)
                .padding(.bottom, Const.Size.sectionBottomPadding)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink(destination: AppTPAboutView()) {
                        AppTPLinkButton(buttonText: UserText.appTPAboutTitle)
                    }
                    
                    Divider()
                        .padding(.leading)
                    
                    NavigationLink(destination: AppTPFAQView()) {
                        AppTPLinkButton(buttonText: UserText.appTPFAQTitle)
                    }
                }
                .background(Color.cellBackground)
                .cornerRadius(Const.Size.cornerRadius)
                .padding(.bottom)
            }
        }
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 0) {
                Section {
                    AppTPToggleView(viewModel: toggleViewModel)
                        .background(Color.cellBackground)
                        .cornerRadius(Const.Size.cornerRadius)
                        .padding(.bottom, Const.Size.sectionBottomPadding)
                }
                
                if viewModel.appTPUsed || viewModel.sections.count > 0 {
                    manageSection
                }

                if viewModel.sections.count > 0 {
                    listState
                } else {
                    emptyState
                }
            }
            .padding()
            .onChange(of: toggleViewModel.firewallStatus) { value in
                if value == .connected {
                    viewModel.appTPUsed = true
                }
            }
        }
        .background(Color.viewBackground)
        .navigationTitle(UserText.appTPNavTitle)
    }
    
    @ViewBuilder
    var scrollWithBackgroud: some View {
        if #available(iOS 16, *) {
            scrollView
                .scrollContentBackground(.hidden)
                .background(Color.viewBackground)
        } else {
            scrollView
                .background(Color.viewBackground)
        }
    }
    
    var body: some View {
        if viewModel.appTPUsed {
            scrollWithBackgroud
        } else {
            OnboardingContainerView(viewModels: OnboardingStepViewModel.onboardingData, enableAppTP: enableAppTPFromOnboarding)
        }
    }
}

private enum Const {
    enum Font {
        static let sectionHeader = UIFont.systemFont(ofSize: 12)
        static let info = UIFont.appFont(ofSize: 16)
    }
    
    enum Size {
        static let cornerRadius: CGFloat = 12
        static let sectionIndentation: CGFloat = 16
        static let sectionHeaderBottom: CGFloat = -2
        static let standardCellHeight: CGFloat = 44
        static let sectionBottomPadding: CGFloat = 32
    }
}

private extension Color {
    static let infoText = Color("AppTPDomainColor")
    static let buttonColor = Color(designSystemColor: .accent)
    static let cellBackground = Color(designSystemColor: .surface)
    static let viewBackground = Color(designSystemColor: .background)
}

#endif
