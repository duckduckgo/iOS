//
//  SyncSettingsViewController+PDFRendering.swift
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

import SwiftUI
import Combine
import SyncUI
import DDGSync

extension SyncSettingsViewController {

    func shareRecoveryPDF() {

        let data = RecoveryPDFGenerator()
            .generate(recoveryCode)

        let pdf = RecoveryCodeItem(data: data)
        navigationController?.visibleViewController?.presentShareSheet(withItems: [pdf],
                                                                       fromView: view)
    }

    func shareCode(_ code: String) {

        navigationController?.visibleViewController?.presentShareSheet(withItems: [code],
                                                                       fromView: view,
                                                                       overrideInterfaceStyle: .dark)
    }

}

private class RecoveryCodeItem: NSObject, UIActivityItemSource {

    let data: Data

    init(data: Data) {
        self.data = data
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return URL(fileURLWithPath: "DuckDuckGo Sync Recovery Code.pdf")
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        data
    }

}
