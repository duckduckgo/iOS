//
//  SettingsRootView.swift
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
import DesignResourcesKit

struct SettingsRootView: View {

    @StateObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var subscriptionNavigationCoordinator = SubscriptionNavigationCoordinator()
    @State private var shouldDisplayDeepLinkSheet: Bool = false
    @State private var shouldDisplayDeepLinkPush: Bool = false
    @State var deepLinkTarget: SettingsViewModel.SettingsDeepLinkSection?

    var body: some View {

        // Hidden navigationLink for programatic navigation
        if #available(iOS 15.0, *) {
            
            if let target = deepLinkTarget {
                NavigationLink(destination: deepLinkDestinationView(for: target),
                               isActive: $shouldDisplayDeepLinkPush) {
                    EmptyView()
                }
            }
        }

        List {
            SettingsPrivacyProtectionsView()
            if #available(iOS 15, *) {
                SettingsSubscriptionView().environmentObject(subscriptionNavigationCoordinator)
            }
            SettingsMainSettingsView()
            SettingsNextStepsView()
            SettingsOthersView()
            SettingsDebugView()
        }
        .navigationBarTitle(UserText.settingsTitle, displayMode: .inline)
        .navigationBarItems(trailing: Button(UserText.navigationTitleDone) {
            viewModel.onRequestDismissSettings?()
        })
        .accentColor(Color(designSystemColor: .textPrimary))
        .environmentObject(viewModel)
        .conditionalInsetGroupedListStyle()

        .onAppear {
            viewModel.onAppear()
        }

        // MARK: Deeplink Modifiers

        .sheet(isPresented: $shouldDisplayDeepLinkSheet,
               onDismiss: {
                    viewModel.onAppear()
                    shouldDisplayDeepLinkSheet = false
                },
               content: {
                    if #available(iOS 15.0, *) {
                        if let target = deepLinkTarget {
                            deepLinkDestinationView(for: target)
                        }
                    }
                })

        .onReceive(viewModel.$deepLinkTarget.removeDuplicates(), perform: { link in
            guard let link else {
                return
            }

            self.deepLinkTarget = link

            switch link.type {
            case .sheet:
                DispatchQueue.main.async {
                    self.shouldDisplayDeepLinkSheet = true
                }
            case .navigationLink:
                DispatchQueue.main.async {
                    self.shouldDisplayDeepLinkPush = true
                }
            case.UIKitView:
                DispatchQueue.main.async {
                    triggerLegacyLink(link)
                }
            }
        })
    }

    // MARK: DeepLink Views
    @available(iOS 15.0, *)
    @ViewBuilder
     func deepLinkDestinationView(for target: SettingsViewModel.SettingsDeepLinkSection) -> some View {
        switch target {
        case .dbp:
            SubscriptionPIRView()
        case .itr:
            SubscriptionITPView()
        case .subscriptionFlow:
            SubscriptionContainerView(currentView: .subscribe).environmentObject(subscriptionNavigationCoordinator)
        case .subscriptionRestoreFlow:
            SubscriptionContainerView(currentView: .restore).environmentObject(subscriptionNavigationCoordinator)
        default:
            EmptyView()
        }
    }

    private func triggerLegacyLink(_ link: SettingsViewModel.SettingsDeepLinkSection) {
        switch link {
        case .netP:
            viewModel.presentLegacyView(.netP)
        default:
            return
        }
    }
}

struct InsetGroupedListStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            return AnyView(content.applyInsetGroupedListStyle())
        } else {
            return AnyView(content)
        }
    }
}

struct SettingsListModifiers: ViewModifier {
    @EnvironmentObject var viewModel: SettingsViewModel
    let title: String?
    let displayMode: NavigationBarItem.TitleDisplayMode

    func body(content: Content) -> some View {
        content
            .navigationBarTitle(title ?? "", displayMode: displayMode)
            .accentColor(Color(designSystemColor: .textPrimary))
            .environmentObject(viewModel)
            .conditionalInsetGroupedListStyle()
            .onAppear {
                viewModel.onAppear()
            }
    }
}

extension View {
    func conditionalInsetGroupedListStyle() -> some View {
        self.modifier(InsetGroupedListStyleModifier())
    }

    func applySettingsListModifiers(title: String? = nil, displayMode: NavigationBarItem.TitleDisplayMode = .inline, viewModel: SettingsViewModel) -> some View {
        self.modifier(SettingsListModifiers(title: title, displayMode: displayMode))
            .environmentObject(viewModel)
    }
}
