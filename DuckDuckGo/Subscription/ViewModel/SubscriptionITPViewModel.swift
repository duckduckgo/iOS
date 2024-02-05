//
//  SubscriptionITPViewModel.swift
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

import Foundation
import UserScript
import Combine
import Core

#if SUBSCRIPTION
@available(iOS 15.0, *)
final class SubscriptionITPViewModel: ObservableObject {
    
    let userScript: IdentityTheftRestorationPagesUserScript
    let subFeature: IdentityTheftRestorationPagesFeature
    var manageITPURL = URL.manageITP
    var viewTitle = UserText.settingsPProITRTitle
    
    enum Constants {
        static let navigationBarHideThreshold = 40.0
    }
    
    // State variables
    var itpURL = URL.manageITP
    @Published var webViewModel: AsyncHeadlessWebViewViewModel
    @Published var shouldShowNavigationBar: Bool = false
    @Published var canNavigateBack: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var canGoBackCancellable: AnyCancellable?
    
    init(userScript: IdentityTheftRestorationPagesUserScript = IdentityTheftRestorationPagesUserScript(),
         subFeature: IdentityTheftRestorationPagesFeature = IdentityTheftRestorationPagesFeature()) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.webViewModel = AsyncHeadlessWebViewViewModel(userScript: userScript,
                                                          subFeature: subFeature,
                                                          settings: AsyncHeadlessWebViewSettings(bounces: false))
    }
    
    // Observe transaction status
    private func setupSubscribers() async {
        
        webViewModel.$scrollPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.shouldShowNavigationBar = value.y > Constants.navigationBarHideThreshold
            }
            .store(in: &cancellables)
        
        canGoBackCancellable = webViewModel.$canGoBack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.canNavigateBack = value
            }
    }
    
    func initializeView() {
        webViewModel.navigationCoordinator.navigateTo(url: manageITPURL )
        Task { await setupSubscribers() }
    }
    
    @MainActor
    private func disableGoBack() {
        canGoBackCancellable?.cancel()
        canNavigateBack = false
    }
    
    @MainActor
    func navigateBack() async {
        await webViewModel.navigationCoordinator.goBack()
    }
    
}
#endif
