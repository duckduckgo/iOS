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

final class CrashCollectionOnboardingViewModel: ObservableObject {

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
    }

    let appSettings: AppSettings
    var onDismiss: (Bool?) -> Void = { _ in }

    /// Used by the presenting controller. Follows `isShowingReport` but with a delay when setting that one to `true`.
    @Published var isViewExpanded: Bool = false

    @Published var isShowingReport: Bool = false {
        didSet {
            if isShowingReport {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isViewExpanded = true
                }
            } else {
                isViewExpanded = false
            }
        }
    }
    private(set) var reportDetails: String?

    func setReportDetails(with payloads: [Data]) {
        guard let firstPayload = payloads.first else {
            reportDetails = nil
            return
        }
        reportDetails = String(data: firstPayload, encoding: .utf8)
    }

    var sendCrashLogs: Bool? {
        get {
            appSettings.sendCrashLogs
        }
        set {
            appSettings.sendCrashLogs = newValue
        }
    }
}
