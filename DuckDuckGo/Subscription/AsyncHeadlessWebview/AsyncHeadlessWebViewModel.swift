//
//  AsyncHeadlessWebViewModel.swift
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

import UserScript
import Core
import Combine

final class AsyncHeadlessWebViewViewModel: ObservableObject {
    weak var userScript: UserScriptMessaging?
    let subFeature: Subfeature?
    let settings: AsyncHeadlessWebViewSettings
    
    private var initialScrollPositionSubject = PassthroughSubject<CGPoint, Never>()
    private var subsequentScrollPositionSubject = PassthroughSubject<CGPoint, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var isFirstUpdate = true
    private var initialDelay = 1
    
    @Published var scrollPosition: CGPoint = .zero
    @Published var url: URL?
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var contentType: String = ""
    @Published var navigationError: Error?
    @Published var allowedDomains: [String]?

    var navigationCoordinator = HeadlessWebViewNavCoordinator(webView: nil)

    init(userScript: UserScriptMessaging? = nil,
         subFeature: Subfeature? = nil,
         settings: AsyncHeadlessWebViewSettings) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.settings = settings
        
        // Delayed publishing first update for scrollPosition
        // To avoid publishing events on view updates
        initialScrollPositionSubject
            .delay(for: .seconds(initialDelay), scheduler: RunLoop.main)
            .merge(with: subsequentScrollPositionSubject)
            .assign(to: &$scrollPosition)
    }
        
    func updateScrollPosition(_ newPosition: CGPoint) {
        if isFirstUpdate {
            initialScrollPositionSubject.send(newPosition)
            isFirstUpdate = false
        } else {
            DispatchQueue.main.async {
                self.subsequentScrollPositionSubject.send(newPosition)
            }
        }
    }
    
    
}
