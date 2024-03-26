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

#if SUBSCRIPTION
@available(iOS 15.0, *)
struct SubscriptionContainerView: View {
    
    enum CurrentView {
        case subscribe, restore
    }
    
    @Environment(\.dismiss) var dismiss
    @State var currentView: CurrentView
    private var flowViewModel: SubscriptionFlowViewModel
    private var restoreViewModel: SubscriptionRestoreViewModel
    private var emailViewModel: SubscriptionEmailViewModel
    
    init(currentView: CurrentView) {
        let userScript = SubscriptionPagesUserScript()
        let subFeature = SubscriptionPagesUseSubscriptionFeature()
        self.currentView = currentView
        flowViewModel = SubscriptionFlowViewModel(userScript: userScript, subFeature: subFeature)
        restoreViewModel = SubscriptionRestoreViewModel(userScript: userScript, subFeature: subFeature)
        emailViewModel = SubscriptionEmailViewModel(userScript: userScript, subFeature: subFeature)
    }
    
    var body: some View {
        switch currentView {
        case .subscribe:
            SubscriptionFlowView(viewModel: flowViewModel,
                                 onDismissStack: { dismiss() },
                                 onRequireRestore: { currentView = .restore })
        case .restore:
            SubscriptionRestoreView(viewModel: restoreViewModel,
                                    emailViewModel: emailViewModel,
                                    onDismissStack: { dismiss() },
                                    onRequirePurchase: { currentView = .subscribe })
        }
        
    }
}
#endif
