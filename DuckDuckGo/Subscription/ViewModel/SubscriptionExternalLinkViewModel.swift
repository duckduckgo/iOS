//
//  SubscriptionExternalLinkViewModel.swift
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
import Core
import Combine

final class SubscriptionExternalLinkViewModel: ObservableObject {
                
    var url: URL
    var allowedDomains: [String]?
    var webViewModel: AsyncHeadlessWebViewViewModel
    
    private var canGoBackCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var canNavigateBack: Bool = false
    
    init(url: URL, allowedDomains: [String]? = nil) {
        let webViewSettings = AsyncHeadlessWebViewSettings(bounces: false,
                                                           allowedDomains: allowedDomains,
                                                           contentBlocking: true)
                
        self.url = url
        self.webViewModel = AsyncHeadlessWebViewViewModel(settings: webViewSettings)
    }
    
    // Observe transaction status
    private func setupSubscribers() async {
        
        canGoBackCancellable = webViewModel.$canGoBack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.canNavigateBack = value
            }
    }
    
    func onFirstAppear() {
        Task { await setupSubscribers() }
        webViewModel.navigationCoordinator.navigateTo(url: url)
    }
    
    private func cleanUp() {
        canGoBackCancellable?.cancel()
        cancellables.removeAll()
    }
    
    @MainActor
    func navigateBack() async {
        await webViewModel.navigationCoordinator.goBack()
    }
    
    deinit {
        cleanUp()
        canGoBackCancellable = nil
    }
    
}
