//
//  SFContentBlockerManagerExtension.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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


import SafariServices

extension SFContentBlockerManager {
    
    struct Constants {
        static let identifier = "com.duckduckgo.DuckDuckGo.ContentBlockerExtension"
    }
    
    public static func reloadContentBlocker() {
        reloadContentBlocker(withIdentifier: Constants.identifier) { error in
            if let error = error {
                Logger.log(text: "Could not reload content blocker in Safari due to \(error)")
                return
            }
            Logger.log(text: "Content blocker rules for Safari reloaded")
        }
    }
}
