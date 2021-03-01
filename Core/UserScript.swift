//
//  UserScript.swift
//  Core
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import BrowserServicesKit

extension UserScript {
        
    // Wrapper to reduce the number of changes required to integrate BrowserServicesKit
    // and reduce the size of the eventual merge conflict when the email feature is ready to be made public
    // This can be removed then
    public func loadJS(_ jsFile: String, withReplacements replacements: [String: String] = [:]) -> String {
        
        return Self.loadJS(jsFile, from: Bundle.core, withReplacements: replacements)
    }
    
}
