//
//  XCTestCaseExtension.swift
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

import XCTest

extension XCTestCase {
    
    func temporaryUserDefaultSuite(with filePath: String) -> String {
        guard let lastPathComponent = NSURL(fileURLWithPath: filePath).lastPathComponent else {
            fatalError("Path should have a last path component")
        }
        
        do {
            let temporaryDirectory = try FileManager.default.url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: FileManager.default.temporaryDirectory,
                create: true
            )
            
            return "\(temporaryDirectory)\(lastPathComponent)"
        } catch {
            fatalError("temporary directory should always be created")
        }
    }
    
    func setupUserDefault(with path: String) {
        let tmpPath = temporaryUserDefaultSuite(with: path)
        UserDefaults.app.removePersistentDomain(forName: tmpPath)
        UserDefaults.app = UserDefaults(suiteName: tmpPath)!
    }

}
