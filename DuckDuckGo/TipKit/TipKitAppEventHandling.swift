//
//  TipKitAppEventHandling.swift
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

import Core
import Foundation
import os.log

protocol TipKitAppEventHandling {
    func appDidFinishLaunching()
}

struct TipKitAppEventHandler: TipKitAppEventHandling {

    private let controller: TipKitController
    private let logger: Logger

    init(controller: TipKitController = .make(),
         logger: Logger = .tipKit) {

        self.controller = controller
        self.logger = logger
    }

    func appDidFinishLaunching() {
        if #available(iOS 17.0, *) {
            // TipKit is temporarily disabled.
            // See https://app.asana.com/0/inbox/1203108348814444/1208724397684354/1208739407931826
            // for more information
            logger.log("TipKit is temporarily disabled.")

            //controller.configureTipKit([
            //    .displayFrequency(.immediate),
            //    .datastoreLocation(.applicationDefault)
            //])
        } else {
            logger.log("TipKit initialization skipped: iOS 17.0 or later is required.")
        }
    }
}
