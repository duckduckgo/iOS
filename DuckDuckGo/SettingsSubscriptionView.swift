//
//  SettingsSubscriptionView.swift
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
import UIKit

#if SUBSCRIPTION
import Subscription
@available(iOS 15.0, *)
struct SettingsSubscriptionView: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @StateObject var subscriptionFlowViewModel =  SubscriptionFlowViewModel()
    @State var isShowingsubScriptionFlow = false
    @State var isShowingDBP = false
    @State var isShowingITP = false
    
    private var subscriptionDescriptionView: some View {
        VStack(alignment: .leading) {
            Text(UserText.settingsPProSubscribe).daxBodyRegular()
            Group {
                Text(UserText.settingsPProDescription).daxFootnoteRegular().padding(.bottom, 5)
                Text(UserText.settingsPProFeatures).daxFootnoteRegular()
            }.foregroundColor(Color(designSystemColor: .textSecondary))
        }
    }
    
    private var learnMoreView: some View {
        Text(UserText.settingsPProLearnMore)
            .daxBodyRegular()
            .foregroundColor(Color.init(designSystemColor: .accent))
    }
    
    private var manageSubscriptionView: some View {
        Text(UserText.settingsPProManageSubscription)
            .daxBodyRegular()
            .foregroundColor(Color.init(designSystemColor: .accent))
    }
     
    private var purchaseSubscriptionView: some View {
        return Group {
            SettingsCustomCell(content: { subscriptionDescriptionView })
            SettingsCustomCell(content: { learnMoreView },
                               action: { isShowingsubScriptionFlow = true },
                               isButton: true )
            .sheet(isPresented: $isShowingsubScriptionFlow) {
                SubscriptionFlowView(viewModel: subscriptionFlowViewModel).interactiveDismissDisabled()
            }
        }
    }
    
    private var subscriptionDetailsView: some View {
        return Group {
            SettingsCellView(label: UserText.settingsPProVPNTitle,
                             subtitle: viewModel.state.networkProtection.status != "" ? viewModel.state.networkProtection.status : nil,
                             action: { viewModel.presentLegacyView(.netP) },
                             disclosureIndicator: true,
                             isButton: true)
            
            
            SettingsCellView(label: UserText.settingsPProDBPTitle,
                             subtitle: UserText.settingsPProDBPSubTitle,
                             action: { isShowingDBP.toggle() }, isButton: true)
            .sheet(isPresented: $isShowingDBP) {
                SubscriptionPIRView()
            }
            
            SettingsCellView(label: UserText.settingsPProITRTitle,
                             subtitle: UserText.settingsPProITRSubTitle,
                             action: { isShowingITP.toggle() }, isButton: true)
            .sheet(isPresented: $isShowingITP) {
                SubscriptionITPView()
            }
             
            
            NavigationLink(destination: SubscriptionSettingsView()) {
                SettingsCustomCell(content: { manageSubscriptionView })
            }
            
        }
    }
    
    var body: some View {
        if viewModel.state.subscription.enabled {
            Section(header: Text(UserText.settingsPProSection)) {
                if viewModel.state.subscription.hasActiveSubscription {
                    subscriptionDetailsView
                } else {
                    purchaseSubscriptionView
                }
            
            }
            // Refresh subscription when dismissing the Subscription Flow
            .onChange(of: isShowingsubScriptionFlow, perform: { value in
                if !value {
                    Task { viewModel.onAppear() }
                }
            })
            
            .onChange(of: viewModel.shouldNavigateToDBP, perform: { value in
                if value {
                    // Allow the sheet to dismiss before presenting a new one
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        isShowingDBP = true
                    }
                }
            })
            
            .onChange(of: viewModel.shouldNavigateToITP, perform: { value in
                if value {
                    // Allow the sheet to dismiss before presenting a new one
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        isShowingITP = true
                    }
                }
            })
            
            .onReceive(subscriptionFlowViewModel.$selectedFeature) { value in
                guard let value else { return }
                viewModel.onAppearNavigationTarget = value
            }
        }
    }
}
#endif
