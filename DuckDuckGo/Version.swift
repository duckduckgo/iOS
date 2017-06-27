//
//  Version.swift
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


import Foundation
import Core

public struct Version {
    
    struct Keys {
        static let name = kCFBundleNameKey as String
        static let buildNumber = kCFBundleVersionKey as String
        static let versionNumber = "CFBundleShortVersionString"
    }
    
    private let bundle: InfoBundle
    
    init(bundle: InfoBundle) {
        self.bundle = bundle
    }
    
    init() {
        self.init(bundle: Bundle.main)
    }
    
    func name() -> String? {
        return bundle.object(forInfoDictionaryKey: Version.Keys.name) as? String
    }
    
    func versionNumber() -> String? {
        return bundle.object(forInfoDictionaryKey: Version.Keys.versionNumber) as? String
    }
    
    func buildNumber() -> String? {
        return bundle.object(forInfoDictionaryKey: Version.Keys.buildNumber) as? String
    }
    
    func localized() -> String? {
        
        guard let name = name() else { return nil }
        guard let versionNumber = versionNumber() else { return nil }
        guard let buildNumber = buildNumber() else { return nil }
        
        guard (versionNumber != buildNumber) else {
            return String.localizedStringWithFormat(UserText.appInfo, name, versionNumber)
        }
        return String.localizedStringWithFormat(UserText.appInfoWithBuild, name, versionNumber, buildNumber)
    }
}

