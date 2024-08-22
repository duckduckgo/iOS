//
//  ZippedPassKitPreviewHelper.swift
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

import Common
import Foundation
import UIKit
import PassKit
import ZIPFoundation
import os.log

class ZippedPassKitPreviewHelper: FilePreview {
    private weak var viewController: UIViewController?
    private let filePath: URL
    
    required init(_ filePath: URL, viewController: UIViewController) {
        self.filePath = filePath
        self.viewController = viewController
    }
    
    func preview() {
        do {
            let passes: [PKPass] = try extractDataEntriesFromZipAtFilePath(self.filePath).compactMap({ try? PKPass(data: $0) })
            if passes.count > 0,
               let controller = PKAddPassesViewController(passes: passes) {
                viewController?.present(controller, animated: true)
            } else {
                Logger.general.error("Can't present passkit: No valid passes in passes file")
            }
        } catch {
            Logger.general.error("Can't present passkit: \(error.localizedDescription, privacy: .public)")
        }
    }
 
    func extractDataEntriesFromZipAtFilePath(_ zipPath: URL) throws -> [Data] {
        var dataObjects = [Data]()
        let archive = try Archive(url: zipPath, accessMode: .read)
        try archive.forEach { entry in
            var passData = Data()
            _ = try archive.extract(entry, skipCRC32: true) { data in
                passData.append(data)
            }
            
            if passData.count > 0 {
                dataObjects.append(passData)
            }
        }

        return dataObjects
    }
}
