//
//  PasswordHider.swift
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

import Foundation

public struct PasswordHider {
    public let password: String
    public var hiddenPassword: String {
        let maximumPasswordDisplayCount = 22
        let passwordCount = password.count > maximumPasswordDisplayCount ? maximumPasswordDisplayCount : password.count
        return String(repeating: "•", count: passwordCount)
    }

    public init(password: String) {
        self.password = password
    }
}
