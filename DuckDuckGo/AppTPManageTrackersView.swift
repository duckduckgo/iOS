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

struct AppTPManageTrackersView: View {
    
    @StateObject var viewModel: AppTPManageTrackersViewModel
    
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
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Section {
                            Button(action: {
                                restoreDefaults()
                            }, label: {
                                HStack {
                                    Spacer()
                                    
                                    Text(UserText.appTPRestoreDefaults)
                                        .font(Font(uiFont: Const.Font.info))
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
                        
                        VStack {
                            ForEach(viewModel.trackerList, id: \.hashValue) { tracker in
                                let showDivider = tracker != viewModel.trackerList.last
                                AppTPManageTrackerCell(tracker: tracker,
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
        }
        .navigationTitle(UserText.appTPManageTrackers)
        .onAppear {
            Task {
                viewModel.buildTrackerList()
            }
        }
    }
}

private enum Const {
    enum Font {
        static let info = UIFont.appFont(ofSize: 16)
    }
    
    enum Size {
        static let cornerRadius: CGFloat = 12
        static let standardCellHeight: CGFloat = 44
    }
}

private extension Color {
    static let cellBackground = Color("AppTPCellBackgroundColor")
    static let viewBackground = Color("AppTPViewBackgroundColor")
    static let buttonTextColor = Color("AppTPToggleColor")
}
