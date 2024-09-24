//
//  SubscriptionContainerView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation
import SwiftUI

struct SubscriptionContainerView: View {
    
    enum CurrentViewType {
        case subscribe, restore, email
    }
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionNavigationCoordinator: SubscriptionNavigationCoordinator
    @State private var currentViewType: CurrentViewType
    private let viewModel: SubscriptionContainerViewModel
    private let flowViewModel: SubscriptionFlowViewModel
    private let restoreViewModel: SubscriptionRestoreViewModel
    private let emailViewModel: SubscriptionEmailViewModel
        
    init(currentView: CurrentViewType,
         viewModel: SubscriptionContainerViewModel) {
        _currentViewType = State(initialValue: currentView)
        self.viewModel = viewModel
        flowViewModel = viewModel.flow
        restoreViewModel = viewModel.restore
        emailViewModel = viewModel.email
    }

    var body: some View {
        VStack {
            switch currentViewType {
            case .subscribe:
                SubscriptionFlowView(viewModel: flowViewModel,
                                     currentView: $currentViewType)
                .environmentObject(subscriptionNavigationCoordinator)
            case .restore:
                SubscriptionRestoreView(viewModel: restoreViewModel,
                                        emailViewModel: emailViewModel,
                                        currentView: $currentViewType)
                .environmentObject(subscriptionNavigationCoordinator)
            case .email:
                SubscriptionEmailView(viewModel: emailViewModel)
            }
        }
    }
}
