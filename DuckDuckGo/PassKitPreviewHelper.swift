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
