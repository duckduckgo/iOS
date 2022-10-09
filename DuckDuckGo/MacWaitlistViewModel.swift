//
//  MacWaitlistViewModel.swift
//  DuckDuckGo
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

import UIKit
import SwiftUI
import Combine
import Core

protocol MacWaitlistViewModelDelegate: AnyObject {
    func macWaitlistViewModelDidOpenShareSheet(_ viewModel: MacWaitlistViewModel, senderFrame: CGRect)
}

@MainActor
final class MacWaitlistViewModel: ObservableObject {
    
    enum ViewAction: Equatable {
        case openShareSheet(CGRect)
        case copyDownloadURLToPasteboard
    }

    weak var delegate: MacWaitlistViewModelDelegate?
    
    private let waitlistRequest: WaitlistRequest
    private let waitlistStorage: MacBrowserWaitlistStorage

    init(waitlistRequest: WaitlistRequest = ProductWaitlistRequest(product: .macBrowser),
         waitlistStorage: MacBrowserWaitlistStorage = MacBrowserWaitlistKeychainStore()) {
        self.waitlistRequest = waitlistRequest
        self.waitlistStorage = waitlistStorage
    }
    
    func perform(action: ViewAction) async {
        switch action {
        case .openShareSheet(let frame): openShareSheet(senderFrame: frame)
        case .copyDownloadURLToPasteboard: copyDownloadUrlToClipboard()
        }
    }
    
    private func openShareSheet(senderFrame: CGRect) {
        self.delegate?.macWaitlistViewModelDidOpenShareSheet(self, senderFrame: senderFrame)
    }
    
    private func copyDownloadUrlToClipboard() {
        UIPasteboard.general.url = AppUrls().macBrowserDownloadURL
    }
    
}
