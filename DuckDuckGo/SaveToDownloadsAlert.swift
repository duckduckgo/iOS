//
//  SaveToDownloadsAlert.swift
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

struct SaveToDownloadsAlert {
    
    static func makeAlert(downloadMetadata: DownloadMetadata,
                          cancelHandler: (() -> Void)? = nil,
                          saveToDownloadsHandler: @escaping () -> Void) -> UIAlertController {
        
        let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        let title = SaveToDownloadsAlert.makeTitle(downloadMetadata: downloadMetadata)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: style)
        alert.overrideUserInterfaceStyle()

        let saveToDownloadsAction = UIAlertAction(title: UserText.actionSaveToDownloads, style: .default) { _ in
            saveToDownloadsHandler()
        }
        
        let cancelAction = UIAlertAction(title: UserText.actionCancel, style: .cancel) { _ in
            cancelHandler?()
        }

        alert.addAction(saveToDownloadsAction)
        alert.addAction(cancelAction)
        return alert
    }
    
    private static func makeTitle(downloadMetadata: DownloadMetadata) -> String? {
        var title = downloadMetadata.filename
        
        if downloadMetadata.expectedContentLength > 0 {
            let size = DownloadsListRowViewModel.byteCountFormatter.string(fromByteCount: downloadMetadata.expectedContentLength)
            title += " (\(size))"
        }
        
        return title
    }
}
