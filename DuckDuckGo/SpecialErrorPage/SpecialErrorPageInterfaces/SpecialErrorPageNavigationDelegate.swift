//
//  SpecialErrorPageNavigationDelegate.swift
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

/// A delegate for handling navigation actions related to special error pages.
protocol SpecialErrorPageNavigationDelegate: AnyObject {
    /// Asks the delegate to close the special error page tab when the web view can't navigate back.
    func closeSpecialErrorPageTab(shouldCreateNewEmptyTab: Bool)
}
