//
//  SubscriptionExernalLinkViewModel.swift
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

#if SUBSCRIPTION
@available(iOS 15.0, *)
final class SubscriptionExternalLinkViewModel: ObservableObject {
            
    @Published var webViewModel: AsyncHeadlessWebViewViewModel
    private var webViewSettings = AsyncHeadlessWebViewSettings(bounces: false,
                                                               javascriptEnabled: false,
                                                               allowedDomains: ["whatismybrowser.com"])
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.webViewModel = AsyncHeadlessWebViewViewModel(settings: webViewSettings)
    }
    
    func initializeView() {
        webViewModel.navigationCoordinator.navigateTo(url: URL(string: "https://www.whatismybrowser.com/detect/is-javascript-enabled")!)
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        
        webViewModel.$url
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                print(value)
            }
            .store(in: &cancellables)
    }
    
}
#endif
