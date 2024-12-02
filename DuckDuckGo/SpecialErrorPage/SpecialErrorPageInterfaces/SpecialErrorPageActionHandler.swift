//
//  SpecialErrorPageActionHandler.swift
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

/// A type that defines actions for handling special error pages.
///
/// This protocol is intended to be adopted by types that need to manage user interactions
/// with special error pages, such as navigating to a site, leaving a site, or presenting
/// advanced information related to the error.
protocol SpecialErrorPageActionHandler {
    /// Handles the action of navigating to the site associated with the error page
    func visitSite()

    /// Handles the action of leaving the site associated with the error page
    func leaveSite()

    /// Handles the action of requesting more detailed information about the error
    func advancedInfoPresented()
}
