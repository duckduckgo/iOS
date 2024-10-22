//
//  TipKitDebugOptionsUIActionHandling.swift
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
import os.log

protocol TipKitDebugOptionsUIActionHandling {
    /// Resets TipKit
    func resetTipKitTapped()
}

struct TipKitDebugOptionsUIActionHandler: TipKitDebugOptionsUIActionHandling {

    private let controller: TipKitController
    private let logger: Logger

    init(controller: TipKitController = .make(),
         logger: Logger = .tipKit) {

        self.controller = controller
        self.logger = logger
    }

    func resetTipKitTapped() {
        if #available(iOS 17.0, *) {
            controller.resetTipKitOnNextAppLaunch()

            ActionMessageView.present(message: "TipKit will reset on next app launch.")
        } else {
            logger.log("TipKit initialization skipped: iOS 17.0 or later is required.")
        }
    }
}
