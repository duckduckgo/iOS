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

struct AppTPActivityView: View {
    @ObservedObject var viewModel: AppTrackingProtectionListViewModel
    @ObservedObject var feedbackModel: AppTrackingProtectionFeedbackModel
    @ObservedObject var toggleViewModel = AppTPToggleViewModel()
    
    // We only want to show "Manage Trackers" and "Report an issue" if the user has enabled AppTP at least once
    @AppStorage("appTPUsed") var appTPUsed: Bool = false
    @State var vpnOn: Bool = false
    
    let imageCache = AppTrackerImageCache()
    
    func imageForState() -> Image {
        return vpnOn ? Image("AppTPEmptyEnabled") : Image("AppTPEmptyDisabled")
    }
    
    func textForState() -> String {
        return vpnOn ? UserText.appTPEmptyEnabledInfo : UserText.appTPEmptyDisabledInfo
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
            Picker("Tracker Sorting", selection: $viewModel.trackerSortingOption) {
                Text("Sort By Count").tag(AppTrackingProtectionListViewModel.TrackerSorting.count)
                Text("Sort By Date").tag(AppTrackingProtectionListViewModel.TrackerSorting.timestamp)
            }
            .pickerStyle(.segmented)
            
            ForEach(viewModel.sections, id: \.name) { section in
                Section(content: {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(section.objects as? [AppTrackerEntity] ?? []) { tracker in
                            let showDivider = tracker != (section.objects?.last as? AppTrackerEntity)
                            AppTPTrackerCell(trackerDomain: tracker.domain,
                                             trackerOwner: tracker.trackerOwner,
                                             trackerCount: tracker.count,
                                             trackerTimestamp: viewModel.format(date: tracker.timestamp),
                                             trackerBucket: tracker.bucket,
                                             debugMode: viewModel.debugModeEnabled,
                                             imageCache: imageCache,
                                             showDivider: showDivider)
                        }
                    }
                    .background(Color.cellBackground)
                    .cornerRadius(Const.Size.cornerRadius)
                }, header: {
                    HStack {
                        Text(viewModel.formattedDate(section.name))
                            .font(Font(uiFont: Const.Font.sectionHeader))
                            .foregroundColor(.infoText)
                            .padding(.top)
                            .padding(.leading, Const.Size.sectionIndentation)
                            .padding(.bottom, Const.Size.sectionHeaderBottom)
                        
                        Spacer()
                    }
                })
            }
            
            Toggle(isOn: $viewModel.debugModeEnabled, label: {
                Text("Show Additional Tracker Information")
            })
            .padding(.top, 8)
        }
    }
    
    var manageSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink(destination: AppTPManageTrackersView(viewModel: AppTPManageTrackersViewModel(),
                                                                    imageCache: imageCache)) {
                    HStack {
                        Text("Manage Trackers") // TODO: Add to UserText
                            .font(Font(uiFont: Const.Font.info))
                            .foregroundColor(Color("AppTPToggleColor"))
                            
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(height: Const.Size.standardCellHeight)
                }
                
                Divider()
                
                NavigationLink(destination: AppTPBreakageFormView(feedbackModel: feedbackModel)) {
                    HStack {
                        Text("Report an issue with an app") // TODO: Add to UserText
                            .font(Font(uiFont: Const.Font.info))
                            .foregroundColor(Color("AppTPToggleColor"))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(height: Const.Size.standardCellHeight)
                }
            }
            .background(Color.cellBackground)
            .cornerRadius(Const.Size.cornerRadius)
            .padding(.bottom)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 0) {
                Section {
                    AppTPToggleView(
                        appTPUsed: $appTPUsed,
                        vpnOn: $vpnOn,
                        viewModel: toggleViewModel
                    )
                        .background(Color.cellBackground)
                        .cornerRadius(Const.Size.cornerRadius)
                        .padding(.bottom)
                }
                
                if appTPUsed || viewModel.sections.count > 0 {
                    manageSection
                }

                if viewModel.sections.count > 0 {
                    listState
                } else {
                    emptyState
                }
            }
            .padding()
        }
        .background(Color.viewBackground)
        .navigationTitle(UserText.appTPNavTitle)
    }
}

private enum Const {
    enum Font {
        static let sectionHeader = UIFont.semiBoldAppFont(ofSize: 15)
        static let info = UIFont.appFont(ofSize: 16)
    }
    
    enum Size {
        static let cornerRadius: CGFloat = 12
        static let sectionIndentation: CGFloat = 16
        static let sectionHeaderBottom: CGFloat = 6
        static let standardCellHeight: CGFloat = 44
    }
}

private extension Color {
    static let infoText = Color("AppTPDomainColor")
    static let cellBackground = Color("AppTPCellBackgroundColor")
    static let viewBackground = Color("AppTPViewBackgroundColor")
}
