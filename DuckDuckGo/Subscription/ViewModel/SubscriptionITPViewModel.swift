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
import Subscription
@available(iOS 15.0, *)
final class SubscriptionITPViewModel: ObservableObject {
    
    let userScript: IdentityTheftRestorationPagesUserScript
    let subFeature: IdentityTheftRestorationPagesFeature
    var manageITPURL = URL.identityTheftRestoration
    var viewTitle = UserText.subscriptionTitle
    
    enum Constants {
        static let navigationBarHideThreshold = 60.0
        static let downloadableContent = ["application/pdf"]
        static let blankURL = "about:blank"
    }
    
    // State variables
    var itpURL = URL.identityTheftRestoration
    @Published var webViewModel: AsyncHeadlessWebViewViewModel
    @Published var shouldShowNavigationBar: Bool = false
    @Published var canNavigateBack: Bool = false
    @Published var isDownloadableContent: Bool = false
    @Published var activityItems: [Any] = []
    @Published var attachmentURL: URL?
    
    @Published var shouldNavigateToExternalURL: URL?
    var shouldShowExternalURLSheet: Bool {
        shouldNavigateToExternalURL != nil
    }
    
    private var currentURL: URL?
    private var allowedDomains = [
        "duckduckgo.com",
        "microsoftonline.com",
        "duosecurity.com",
    ]

    private var cancellables = Set<AnyCancellable>()
    private var canGoBackCancellable: AnyCancellable?
    
    init(userScript: IdentityTheftRestorationPagesUserScript = IdentityTheftRestorationPagesUserScript(),
         subFeature: IdentityTheftRestorationPagesFeature = IdentityTheftRestorationPagesFeature()) {
        self.userScript = userScript
        self.subFeature = subFeature
        
        let webViewSettings = AsyncHeadlessWebViewSettings(bounces: false,
                                                           allowedDomains: allowedDomains,
                                                           contentBlocking: false)
        
        self.webViewModel = AsyncHeadlessWebViewViewModel(userScript: userScript,
                                                          subFeature: subFeature,
                                                          settings: webViewSettings)
    }
    
    // Observe transaction status
    private func setupSubscribers() async {
        
        webViewModel.$scrollPosition
            .receive(on: DispatchQueue.main)
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] value in
                self?.shouldShowNavigationBar = (value.y > Constants.navigationBarHideThreshold)
            }
            .store(in: &cancellables)
        
        webViewModel.$contentType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let strongSelf = self else { return }

                if Constants.downloadableContent.contains(value) {
                    strongSelf.isDownloadableContent = true
                    guard let url = strongSelf.currentURL else { return }
                    Task {
                        // We are using a dummy PDF for testing, as the real PDF's are behind the internal user login
                        if let downloadURL = URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf") {
                            await strongSelf.downloadAttachment(from: downloadURL)
                        }
                        // if let downloadURL = url {
                        // await strongSelf.downloadAttachment(from: downloadURL)
                    }
                }
            }
            .store(in: &cancellables)
        
        webViewModel.$url
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                guard let self = self, let url = url else { return }
                
                // Check if allowedDomains is empty or if the URL is valid or part of the allowed domains
                if self.allowedDomains.isEmpty ||
                    self.allowedDomains.contains(where: { url.isPart(ofDomain: $0) }),
                    self.shouldNavigateToExternalURL == nil {
                    self.isDownloadableContent = false
                    self.currentURL = url
                } else {
                    // Fire up navigation in a separate View
                    if url.absoluteString != Constants.blankURL {
                        self.shouldNavigateToExternalURL = url
                    }
                }
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
    
    private func downloadAttachment(from url: URL) async {
        if let (temporaryURL, _) = try? await URLSession.shared.download(from: url) {
            let fileManager = FileManager.default
            
            let fileName = url.lastPathComponent
            
            let tempDirectory = fileManager.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent(fileName)
            
            if fileManager.fileExists(atPath: tempFileURL.path) {
                try? fileManager.removeItem(at: tempFileURL)
            }
            try? fileManager.moveItem(at: temporaryURL, to: tempFileURL)
            DispatchQueue.main.async {
                self.attachmentURL = tempFileURL
            }
        }
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
