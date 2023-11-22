//
//  FilePreviewHelper.swift
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

struct FilePreviewHelper {
    
    static func fileHandlerForDownload(_ download: Download, viewController: UIViewController) -> FilePreview? {
        guard let filePath = download.location else { return nil }
        switch download.mimeType {
        case .passbook:
            return PassKitPreviewHelper(filePath, viewController: viewController)
        default:
            return QuickLookPreviewHelper(filePath, viewController: viewController)
        }
    }
    
    static func canAutoPreviewMIMEType(_ mimeType: MIMEType) -> Bool {
        switch mimeType {
        case .passbook:
            return UIDevice.current.userInterfaceIdiom == .phone

        case .reality, .usdz, .calendar:
            return true
        default:
            return false
        }
    }
}
