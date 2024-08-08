//
//  VPNFeedbackFormViewModel.swift
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

final class VPNFeedbackFormViewModel: ObservableObject {

    enum ViewState {
        case feedbackPending
        case feedbackSending
        case feedbackSendingFailed
        case feedbackSent

        var canSubmit: Bool {
            switch self {
            case .feedbackPending: return true
            case .feedbackSending: return false
            case .feedbackSendingFailed: return true
            case .feedbackSent: return false
            }
        }
    }

    @Published var viewState: ViewState = .feedbackPending {
        didSet {
            updateSubmitButtonStatus()
        }
    }

    @Published var feedbackFormText: String = "" {
        didSet {
            updateSubmitButtonStatus()
        }
    }
    
    @Published private(set) var submitButtonEnabled: Bool = false

    var categoryName: String {
        category.displayName
    }

    private let metadataCollector: VPNMetadataCollector
    private let feedbackSender: VPNFeedbackSender
    private let category: VPNFeedbackCategory

    init(metadataCollector: VPNMetadataCollector,
         feedbackSender: VPNFeedbackSender = DefaultVPNFeedbackSender(),
         category: VPNFeedbackCategory) {
        self.metadataCollector = metadataCollector
        self.feedbackSender = feedbackSender
        self.category = category
    }

    @MainActor
    func sendFeedback() async -> Bool {
        viewState = .feedbackSending

        do {
            let metadata = await metadataCollector.collectVPNMetadata()
            try await feedbackSender.send(metadata: metadata, category: category, userText: feedbackFormText)
            viewState = .feedbackSent
            return true
        } catch {
            viewState = .feedbackSendingFailed
        }

        return false
    }

    private func updateSubmitButtonStatus() {
        self.submitButtonEnabled = viewState.canSubmit && !feedbackFormText.isEmpty
    }

}
