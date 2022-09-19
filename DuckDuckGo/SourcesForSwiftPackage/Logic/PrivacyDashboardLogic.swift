//
//  PrivacyDashboardLogic.swift
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import WebKit
import Combine

public final class PrivacyDashboardLogic: NSObject {
    
    @Published public var themeName: String?
    
    public var onProtectionSwitchChange: ((Bool) -> Void)?
    public var onCloseTapped: (() -> Void)?
    public var onShowReportBrokenSiteTapped: (() -> Void)?
    
    public private(set) weak var privacyInfo: PrivacyInfo?
    private weak var webView: WKWebView?
    
    private let privacyDashboardScript = PrivacyDashboardUserScript()
    private var cancellables = Set<AnyCancellable>()

    public init(privacyInfo: PrivacyInfo?) {
        self.privacyInfo = privacyInfo
    }
    
    public func cleanUp() {
        cancellables.removeAll()
        
        privacyDashboardScript.messageNames.forEach { messageName in
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: messageName)
        }
    }
    
    public func setup(for webView: WKWebView) {
        self.webView = webView
        
        webView.navigationDelegate = self
        
        loadPrivacyDashboardUserScript()
        loadPrivacyDashboardHTML()
    }
    
    public func updatePrivacyInfo(_ privacyInfo: PrivacyInfo?) {
        cancellables.removeAll()
        self.privacyInfo = privacyInfo
        subscribeToDataModelChanges()
        sendProtectionStatus()
    }
    
    public func didStartRulesCompilation() {
        guard let webView = self.webView else { return }
        privacyDashboardScript.setIsPendingUpdates(true, webView: webView)
    }
    
    public func didFinishRulesCompilation() {
        guard let webView = self.webView else { return }
        privacyDashboardScript.setIsPendingUpdates(false, webView: webView)
    }
    
    private func loadPrivacyDashboardUserScript() {
        privacyDashboardScript.delegate = self
        
        webView?.configuration.userContentController.addUserScript(privacyDashboardScript.makeWKUserScript())

        privacyDashboardScript.messageNames.forEach { messageName in
            webView?.configuration.userContentController.add(privacyDashboardScript, name: messageName)
        }
    }
    
    private func loadPrivacyDashboardHTML() {
//        guard !isLoaded, let url = Bundle.privacyDashboardURL else { return }
        
        guard let url = Bundle.privacyDashboardURL else { return }
        webView?.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent().deletingLastPathComponent())
    }
}

extension PrivacyDashboardLogic: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        subscribeToDataModelChanges()
        
        sendProtectionStatus()
//        sendPendingUpdates() // used while recompiling TDS on toggle
        sendParentEntity()

//        isLoaded = true // <-- got rid of it temporarly
    }
    
    private func subscribeToDataModelChanges() {
        subscribeToTheme()
//        subscribeToPermissions() // not yet available
        subscribeToTrackerInfo()
        subscribeToConnectionUpgradedTo()
        subscribeToServerTrust()
//        subscribeToConsentManaged() // not yet available
    }
    
    private func subscribeToTheme() {
        $themeName
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] themeName in
                guard let self = self, let webView = self.webView else { return }
                self.privacyDashboardScript.setTheme(themeName, webView: webView)
            })
            .store(in: &cancellables)
    }

    private func subscribeToTrackerInfo() {
        privacyInfo?.$trackerInfo
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] trackerInfo in
                guard let self = self, let url = self.privacyInfo?.url, let webView = self.webView else { return }
                self.privacyDashboardScript.setTrackerInfo(url, trackerInfo: trackerInfo, webView: webView)
            })
            .store(in: &cancellables)
    }
    
    private func subscribeToConnectionUpgradedTo() {
        privacyInfo?.$connectionUpgradedTo
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] connectionUpgradedTo in
                guard let self = self, let webView = self.webView else { return }
                let upgradedHttps = connectionUpgradedTo != nil
                self.privacyDashboardScript.setUpgradedHttps(upgradedHttps, webView: webView)
            })
            .store(in: &cancellables)
    }
    
    private func subscribeToServerTrust() {
        privacyInfo?.$serverTrust
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .map { serverTrust in
                ServerTrustViewModel(serverTrust: serverTrust)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] serverTrustViewModel in
                guard let self = self, let serverTrustViewModel = serverTrustViewModel, let webView = self.webView else { return }
                self.privacyDashboardScript.setServerTrust(serverTrustViewModel, webView: webView)
            })
            .store(in: &cancellables)
    }
    
    private func sendProtectionStatus() {
        guard let webView = self.webView else { return }
        privacyDashboardScript.setProtectionStatus(privacyInfo?.isProtected ?? false, webView: webView)
    }
    
//    private func sendPendingUpdates() {
//        guard let domain = tabViewModel?.tab.content.url?.host else {
//            assertionFailure("PrivacyDashboardViewController: no domain available")
//            return
//        }
//
//        self.privacyDashboardScript.setIsPendingUpdates(pendingUpdates.values.contains(domain), webView: self.webView)
//    }
    
    private func sendParentEntity() {
        guard let webView = self.webView else { return }
        privacyDashboardScript.setParentEntity(privacyInfo?.parentEntity, webView: webView)
    }
}

extension PrivacyDashboardLogic: PrivacyDashboardUserScriptDelegate {

    func userScript(_ userScript: PrivacyDashboardUserScript, didChangeProtectionStateTo isProtected: Bool) {
        onProtectionSwitchChange?(isProtected)
    }

//    func userScript(_ userScript: PrivacyDashboardUserScript, didSetPermission permission: PermissionType, to state: PermissionAuthorizationState) {
//        guard let domain = tabViewModel?.tab.content.url?.host else {
//            assertionFailure("PrivacyDashboardViewController: no domain available")
//            return
//        }
//
//        PermissionManager.shared.setPermission(state.persistedPermissionDecision, forDomain: domain, permissionType: permission)
//    }

//    func userScript(_ userScript: PrivacyDashboardUserScript, setPermission permission: PermissionType, paused: Bool) {
//        tabViewModel?.tab.permissions.set([permission], muted: paused)
//    }

    func userScript(_ userScript: PrivacyDashboardUserScript, setHeight height: Int) {
//        NSAnimationContext.runAnimationGroup { [weak self] context in
//            context.duration = 1/3
//            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            self?.contentHeightConstraint.animator().constant = CGFloat(height)
//        }
    }
    
    func userScriptDidRequestClosing(_ userScript: PrivacyDashboardUserScript) {
        onCloseTapped?()
    }
    
    func userScriptDidRequestShowReportBrokenSite(_ userScript: PrivacyDashboardUserScript) {
        onShowReportBrokenSiteTapped?()
    }
}
