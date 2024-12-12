//
//  CrashCollectionOnboardingViewModel.swift
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
import SwiftUI
import Crashes

final class CrashCollectionOnboardingViewModel: ObservableObject {

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
    }

    let appSettings: AppSettings
    var onDismiss: (CrashCollectionOptInStatus) -> Void = { _ in }

    func toggleReportVisible(animated: Bool = true) {
        if isReportVisible {
            hideReport(animated: animated)
        } else {
            showReport(animated: animated)
        }
    }

    func showReport(animated: Bool = true) {
        withAnimation(animated ? .default : nil) {
            isReportVisible = true
        }
        showReportButtonMode = .hideDetails
    }

    func hideReport(animated: Bool = true) {
        withAnimation(animated ? .default : nil) {
            isReportVisible = false
        }
        showReportButtonMode = .showDetails
    }

    func setReportDetails(with payloads: [Data]) {
        guard let firstPayload = payloads.first else {
            reportDetails = nil
            return
        }
        reportDetails = String(data: firstPayload, encoding: .utf8)
    }

    /**
     * Boolean value deciding whether the crash report contents are currently presented in the view.
     *
     * Showing crash report contents causes the modal view to expand to full screen (on iOS 16 and above, older OSes
     * present the modal in full screen at all times). Expanding the view while rendering crash report contents
     * is causing glitches so we're using 2 properties here:
     * - `isReportVisible` controls whether the report is shown on the view
     * - `isViewExpanded` controls whether the view is expanded (it's disregarded on pre iOS 16 devices).
     *
     * Updates to this property are mirrored to `isViewExpanded`, but to avoid glitches in the UI, when showing the report,
     * view is expanded after a slight delay.
     */
    @Published private(set) var isReportVisible: Bool = false {
        didSet {
            if isReportVisible {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isViewExpanded = true
                }
            } else {
                isViewExpanded = false
            }
        }
    }

    /**
     * Used by the presenting controller. Follows `isReportVisible` but with a delay when setting that one to `true`.
     */
    @Published private(set) var isViewExpanded: Bool = false

    /**
     * Responsible for the UI of the button toggling crash report details visibility.
     *
     * Follows `isReportVisible`, but never animates changes.
     */
    @Published private(set) var showReportButtonMode: ShowReportButtonMode = .showDetails
    enum ShowReportButtonMode {
        case showDetails, hideDetails
    }

    private(set) var reportDetails: String?

    var crashCollectionOptInStatus: CrashCollectionOptInStatus {
        get {
            appSettings.crashCollectionOptInStatus
        }
        set {
            appSettings.crashCollectionOptInStatus = newValue
            if appSettings.crashCollectionOptInStatus == .optedOut {
                let crashCollection = CrashCollection.init(crashReportSender: CrashReportSender(platform: .iOS,
                                                                                                pixelEvents: CrashReportSender.pixelEvents))
                crashCollection.clearCRCID()
            }
        }
    }
}
