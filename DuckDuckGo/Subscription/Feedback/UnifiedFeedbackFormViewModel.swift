//
//  UnifiedFeedbackFormViewModel.swift
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

import Combine
import SwiftUI

final class UnifiedFeedbackFormViewModel: ObservableObject {
    enum Source: String {
        case settings
        case ppro
        case vpn
        case pir
        case itr
        case unknown
    }

    enum ViewState {
        case feedbackPending
        case feedbackSending
        case feedbackSendingFailed
        case feedbackSent
        case feedbackCanceled

        var canSubmit: Bool {
            switch self {
            case .feedbackPending: return true
            case .feedbackSending: return false
            case .feedbackSendingFailed: return true
            case .feedbackSent: return false
            case .feedbackCanceled: return false
            }
        }
    }

    enum ViewAction {
        case submit
        case faqClick
        case reportShow
        case reportActions
        case reportCategory
        case reportSubcategory
        case reportFAQClick
        case reportSubmitShow
    }

    @Published var viewState: ViewState {
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
    @Published var selectedReportType: String? {
        didSet {
            selectedCategory = ""
        }
    }
    @Published var selectedCategory: String? {
        didSet {
            selectedSubcategory = ""
        }
    }
    @Published var selectedSubcategory: String? {
        didSet {
            feedbackFormText = ""
        }
    }

    var usesCompactForm: Bool {
        guard let selectedReportType else { return false }
        switch UnifiedFeedbackReportType(rawValue: selectedReportType) {
        case .reportIssue:
            return false
        default:
            return true
        }
    }

    private let vpnMetadataCollector: any UnifiedMetadataCollector
    private let defaultMetadataCollector: any UnifiedMetadataCollector
    private let feedbackSender: any UnifiedFeedbackSender

    let source: String

    init(vpnMetadataCollector: any UnifiedMetadataCollector,
         defaultMetadatCollector: any UnifiedMetadataCollector = DefaultMetadataCollector(),
         feedbackSender: any UnifiedFeedbackSender = DefaultFeedbackSender(),
         source: Source = .unknown) {
        self.viewState = .feedbackPending

        self.vpnMetadataCollector = vpnMetadataCollector
        self.defaultMetadataCollector = defaultMetadatCollector
        self.feedbackSender = feedbackSender
        self.source = source.rawValue
    }

    @MainActor
    func process(action: ViewAction) async {
        switch action {
        case .submit:
            self.viewState = .feedbackSending

            do {
                try await sendFeedback()
                self.viewState = .feedbackSent
            } catch {
                self.viewState = .feedbackSendingFailed
            }

            NotificationCenter.default.post(name: .unifiedFeedbackNotification, object: nil)
        case .faqClick:
            await openFAQ()
        case .reportShow:
            await feedbackSender.sendFormShowPixel()
        case .reportActions:
            await feedbackSender.sendActionsScreenShowPixel(source: source)
        case .reportCategory:
            if let selectedReportType {
                await feedbackSender.sendCategoryScreenShow(source: source,
                                                            reportType: selectedReportType)
            }
        case .reportSubcategory:
            if let selectedReportType, let selectedCategory {
                await feedbackSender.sendSubcategoryScreenShow(source: source,
                                                               reportType: selectedReportType,
                                                               category: selectedCategory)
            }
        case .reportFAQClick:
            if let selectedReportType, let selectedCategory, let selectedSubcategory {
                await feedbackSender.sendSubmitScreenFAQClickPixel(source: source,
                                                                   reportType: selectedReportType,
                                                                   category: selectedCategory,
                                                                   subcategory: selectedSubcategory)
            }
        case .reportSubmitShow:
            if let selectedReportType, let selectedCategory, let selectedSubcategory {
                await feedbackSender.sendSubmitScreenShowPixel(source: source,
                                                               reportType: selectedReportType,
                                                               category: selectedCategory,
                                                               subcategory: selectedSubcategory)
            }
        }
    }

    private func openFAQ() async {
        guard let selectedReportType, UnifiedFeedbackReportType(rawValue: selectedReportType) == .reportIssue,
              let selectedCategory, let category = UnifiedFeedbackCategory(rawValue: selectedCategory),
              let selectedSubcategory else {
            return
        }

        let url: URL? = {
        switch category {
            case .subscription: return PrivacyProFeedbackSubcategory(rawValue: selectedSubcategory)?.url
            case .vpn: return VPNFeedbackSubcategory(rawValue: selectedSubcategory)?.url
            case .pir: return PIRFeedbackSubcategory(rawValue: selectedSubcategory)?.url
            case .itr: return ITRFeedbackSubcategory(rawValue: selectedSubcategory)?.url
            }
        }()

        if let url {
            await UIApplication.shared.open(url)
        }
    }

    private func sendFeedback() async throws {
        guard let selectedReportType else { return }
        switch UnifiedFeedbackReportType(rawValue: selectedReportType) {
        case nil:
            return
        case .requestFeature:
            try await feedbackSender.sendFeatureRequestPixel(description: feedbackFormText,
                                                             source: source)
        case .general:
            try await feedbackSender.sendGeneralFeedbackPixel(description: feedbackFormText,
                                                              source: source)
        case .reportIssue:
            try await reportProblem()
        }
    }

    private func reportProblem() async throws {
        guard let selectedCategory, let selectedSubcategory else { return }
        switch UnifiedFeedbackCategory(rawValue: selectedCategory) {
        case .vpn:
            let metadata = await vpnMetadataCollector.collectMetadata()
            try await feedbackSender.sendReportIssuePixel(source: source,
                                                          category: selectedCategory,
                                                          subcategory: selectedSubcategory,
                                                          description: feedbackFormText,
                                                          metadata: metadata as? VPNMetadata)
        default:
            let metadata = await defaultMetadataCollector.collectMetadata()
            try await feedbackSender.sendReportIssuePixel(source: source,
                                                          category: selectedCategory,
                                                          subcategory: selectedSubcategory,
                                                          description: feedbackFormText,
                                                          metadata: metadata as? DefaultFeedbackMetadata)
        }
    }

    private func updateSubmitButtonStatus() {
        self.submitButtonEnabled = viewState.canSubmit && !feedbackFormText.isEmpty
    }

}
