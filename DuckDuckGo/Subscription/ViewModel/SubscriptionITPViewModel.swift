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
import Subscription

final class SubscriptionITPViewModel: ObservableObject {
    
    var userScript: IdentityTheftRestorationPagesUserScript?
    var subFeature: IdentityTheftRestorationPagesFeature?
    let manageITPURL: URL
    var viewTitle = UserText.settingsPProITRTitle
    
    enum Constants {
        static let downloadableContent = ["application/pdf"]
        static let blankURL = "about:blank"
        static let externalSchemes =  ["tel", "sms", "facetime"]
    }
    
    // State variables
    let itpURL: URL
    @Published var canNavigateBack: Bool = false
    @Published var isDownloadableContent: Bool = false
    @Published var activityItems: [Any] = []
    @Published var attachmentURL: URL?
    @Published var navigationError: Bool = false
    var webViewModel: AsyncHeadlessWebViewViewModel
    
    @Published var shouldNavigateToExternalURL: URL?
    var shouldShowExternalURLSheet: Bool {
        shouldNavigateToExternalURL != nil
    }
    
    private var currentURL: URL?
    private static let allowedDomains = [ "duckduckgo.com" ]
    
    private var externalLinksViewModel: SubscriptionExternalLinkViewModel?
    // Limit navigation to these external domains
    private var externalAllowedDomains = ["irisidentityprotection.com"]

    private var cancellables = Set<AnyCancellable>()
    private var canGoBackCancellable: AnyCancellable?

    init(subscriptionManager: SubscriptionManager) {
        self.itpURL = subscriptionManager.url(for: .identityTheftRestoration)
        self.manageITPURL = self.itpURL
        self.userScript = IdentityTheftRestorationPagesUserScript()
        self.subFeature = IdentityTheftRestorationPagesFeature(subscriptionManager: subscriptionManager)

        let webViewSettings = AsyncHeadlessWebViewSettings(bounces: false,
                                                           allowedDomains: Self.allowedDomains,
                                                           contentBlocking: false)
        
        self.webViewModel = AsyncHeadlessWebViewViewModel(userScript: userScript,
                                                          subFeature: subFeature,
                                                          settings: webViewSettings)
    }
        
    private func setupSubscribers() async {
        
        webViewModel.$navigationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.navigationError = error != nil ? true : false
                }
                
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
                        await strongSelf.downloadAttachment(from: url)
                    }
                }
            }
            .store(in: &cancellables)
        
        webViewModel.$url
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                guard let self = self, let url = url else { return }
                
                // Check if allowedDomains is empty or if the URL is valid or part of the allowed domains
                if Self.allowedDomains.isEmpty ||
                    Self.allowedDomains.contains(where: { url.isPart(ofDomain: $0) }),
                    self.shouldNavigateToExternalURL == nil {
                    self.isDownloadableContent = false
                    self.currentURL = url
                } else {
                    // Fire up navigation in a separate View (if a valid link)
                    if url.absoluteString != Constants.blankURL &&
                       !Constants.externalSchemes.contains(url.scheme ?? "") {
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

    
    func onFirstAppear() {
        webViewModel.navigationCoordinator.navigateTo(url: manageITPURL )
        Task { await setupSubscribers() }
        Pixel.fire(pixel: .privacyProIdentityRestorationSettings)
    }
    
    private func cleanUp() {
        canGoBackCancellable?.cancel()
        cancellables.removeAll()
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
    
    func getExternalLinksViewModel(url: URL) -> SubscriptionExternalLinkViewModel {
        if let existingModel = externalLinksViewModel {
            return existingModel
        } else {
            let model = SubscriptionExternalLinkViewModel(url: url, allowedDomains: externalAllowedDomains)
            externalLinksViewModel = model
            return model
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
    
    deinit {
        cleanUp()
        canGoBackCancellable = nil
        self.userScript = nil
        self.subFeature = nil
    }
    
}
