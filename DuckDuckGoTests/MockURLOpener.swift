//
//  MockURLOpener.swift
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
@testable import Core

final class MockURLOpener: URLOpener {
    private(set) var didCallCanOpenURL = false
    private(set) var didCallOpenURL = false
    private(set) var capturedURL: URL?

    var canOpenURL = false

    func canOpenURL(_ url: URL) -> Bool {
        didCallCanOpenURL = true
        capturedURL = url
        return canOpenURL
    }

    func open(_ url: URL) {
        didCallOpenURL = true
        capturedURL = url
    }

}
