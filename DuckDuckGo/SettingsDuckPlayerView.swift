//
//  SettingsDuckPlayerView.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import Core
import SwiftUI
import DesignResourcesKit
import DuckUI

struct SettingsDuckPlayerView: View {
    private static let learnMoreURL = URL(string: "https://duckduckgo.com/duckduckgo-help-pages/duck-player/")!

    /// The ContingencyMessageView may be redrawn multiple times in the onAppear method if the user scrolls it outside the list bounds.
    /// This property ensures that the associated action is only triggered once per viewing session, preventing redundant executions.
    @State private var hasFiredSettingsDisplayedPixel = false

    @EnvironmentObject var viewModel: SettingsViewModel
    var body: some View {
        List {
            if viewModel.shouldDisplayDuckPlayerContingencyMessage {
                Section {
                    ContingencyMessageView {
                        viewModel.openDuckPlayerContingencyMessageSite()
                    }.onAppear {
                        if !hasFiredSettingsDisplayedPixel {
                            Pixel.fire(pixel: .duckPlayerContingencySettingsDisplayed)
                            hasFiredSettingsDisplayedPixel = true
                        }
                    }
                }
            }

            if !viewModel.shouldDisplayDuckPlayerContingencyMessage {
                VStack(alignment: .center) {
                    Image("SettingsDuckPlayerHero")
                        .padding(.top, -20) // Adjust for the image padding

                    Text(UserText.duckPlayerFeatureName)
                        .daxTitle3()

                    Text(UserText.settingsDuckPlayerInfoText)
                        .daxBodyRegular()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                        .padding(.top, 12)

                    Link(UserText.settingsDuckPlayerLearnMore,
                         destination: SettingsDuckPlayerView.learnMoreURL)
                    .daxBodyRegular()
                    .accentColor(Color.init(designSystemColor: .accent))
                }
                .listRowBackground(Color.clear)
            }

            Section {
                SettingsPickerCellView(label: UserText.settingsOpenVideosInDuckPlayerLabel,
                                       options: DuckPlayerMode.allCases,
                                       selectedOption: viewModel.duckPlayerModeBinding)
                .disabled(viewModel.shouldDisplayDuckPlayerContingencyMessage)
                
                if (viewModel.state.duckPlayerOpenInNewTabEnabled || viewModel.isInternalUser) && !viewModel.state.duckPlayerNativeUI {
                        SettingsCellView(label: UserText.settingsOpenDuckPlayerNewTabLabel,
                                         accessory: .toggle(isOn: viewModel.duckPlayerOpenInNewTabBinding))
                    
                }
                
            }
            
            /// Experimental features for internal users
            if viewModel.isInternalUser && UIDevice.current.userInterfaceIdiom == .phone {
                Section("Experimental (Internal only)", content: {
                    SettingsCellView(label: "Use Native UI (Alpha)", accessory: .toggle(isOn: viewModel.duckPlayerNativeUI))
                    if viewModel.appSettings.duckPlayerNativeUI {
                        SettingsCellView(label: "Autoplay Videos", accessory: .toggle(isOn: viewModel.duckPlayerAutoplay))
                    }
                })
            }
        }
        .applySettingsListModifiers(title: UserText.duckPlayerFeatureName,
                                    displayMode: .inline,
                                    viewModel: viewModel)
    }
}

private struct ContingencyMessageView: View {
    let buttonCallback: () -> Void

    private enum Copy {
        static let title: String = UserText.duckPlayerContingencyMessageTitle
        static let message: String = UserText.duckPlayerContingencyMessageBody
        static let buttonTitle: String = UserText.duckPlayerContingencyMessageCTA
    }
    private enum Constants {
        static let imageName: String = "WarningYoutube"
        static let imageSize: CGSize = CGSize(width: 48, height: 48)
        static let buttonCornerRadius: CGFloat = 8.0
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(Constants.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.imageSize.width, height: Constants.imageSize.height)
                .padding(.bottom, 8)

            Text(Copy.title)
                .daxHeadline()
                .foregroundColor(Color(designSystemColor: .textPrimary))

            Text(Copy.message)
                .daxBodyRegular()
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .foregroundColor(Color(designSystemColor: .textPrimary))

            Button {
                buttonCallback()
            } label: {
                Text(Copy.buttonTitle)
                    .bold()
            }
            .buttonStyle(SecondaryFillButtonStyle(compact: true, fullWidth: false))
            .padding(10)
        }
    }
}
