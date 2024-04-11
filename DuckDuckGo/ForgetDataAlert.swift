//
//  ForgetDataAlert.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class ForgetDataAlert {
    
    static func buildAlert(cancelHandler: (() -> Void)? = nil, forgetTabsAndDataHandler: @escaping () -> Void) -> UIAlertController {
        
        let additionalDescription = ongoingDownloadsInProgress() ? UserText.fireButtonInterruptingDownloadsAlertDescription : nil
        
        let alert = UIAlertController(title: additionalDescription, message: nil, preferredStyle: .actionSheet)

        let forgetTabsAndDataAction = UIAlertAction(title: UserText.actionForgetAll, style: .destructive) { _ in
            forgetTabsAndDataHandler()
        }

        forgetTabsAndDataAction.accessibilityIdentifier = "alert.forget-data.confirm"

        let cancelAction = UIAlertAction(title: UserText.actionCancel, style: .cancel) { _ in
            cancelHandler?()
        }

        cancelAction.accessibilityIdentifier = "alert.forget-data.cancel"

        alert.addAction(forgetTabsAndDataAction)
        alert.addAction(cancelAction)

        return alert
    }
    
    static private func ongoingDownloadsInProgress() -> Bool {
        let allDownloads = AppDependencyProvider.shared.downloadManager.downloadList
        let ongoingDownloads = allDownloads.filter { $0.isRunning && !$0.temporary }
        return !ongoingDownloads.isEmpty
    }
}
