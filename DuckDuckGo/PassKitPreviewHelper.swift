//
//  PassKitPreviewHelper.swift
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

import Common
import UIKit
import PassKit

import ZIPFoundation

class PassKitPreviewHelper: FilePreview {
    private weak var viewController: UIViewController?
    private let filePath: URL

    required init(_ filePath: URL, viewController: UIViewController) {
        self.filePath = filePath
        self.viewController = viewController
    }
    
    func preview() {
        do {
            let data = try Data(contentsOf: self.filePath)
            let pass = try PKPass(data: data)
            if let controller = PKAddPassesViewController(pass: pass) {
                viewController?.present(controller, animated: true)
            }
        } catch {
            os_log("Can't present passkit: %s", type: .debug, error.localizedDescription)
        }
    }
}

class ZippedPassKitPreviewHelper: FilePreview {
    private weak var viewController: UIViewController?
    private let filePath: URL
    
    required init(_ filePath: URL, viewController: UIViewController) {
        self.filePath = filePath
        self.viewController = viewController
    }
    
    func preview() {
        if let passes: [PKPass] = extractDataFromZip(at: self.filePath)?.compactMap({ try? PKPass(data: $0) }),
           passes.count > 0,
           let controller = PKAddPassesViewController(passes: passes) {
            viewController?.present(controller, animated: true)
        } else {
            os_log("Can't present passkit: No passes in passes file", type: .debug)
        }
    }
 
    func extractDataFromZip(at zipPath: URL) -> [Data]? {
        var dataObjects = [Data]()
        do {
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
        } catch {
            os_log("Error reading pkpasses file: %s", type: .debug, error.localizedDescription)
            return nil
        }

        return dataObjects
    }
}
