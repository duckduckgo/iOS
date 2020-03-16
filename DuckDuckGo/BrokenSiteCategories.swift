//
//  BrokenSiteCategories.swift
//  DuckDuckGo
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

import Foundation

struct BrokenSite {
    
    enum Category: String, CaseIterable {
        case images
        case paywall
        case comments
        case videos
        case links
        case content
        case login
        case unsupported
        case other
        
        var categoryText: String {
            switch self {
            case .images:
                return UserText.brokenSiteCategoryImages
            case .paywall:
                return UserText.brokenSiteCategoryPaywall
            case .comments:
                return UserText.brokenSiteCategoryComments
            case .videos:
                return UserText.brokenSiteCategoryVideos
            case .links:
                return UserText.brokenSiteCategoryLinks
            case .content:
                return UserText.brokenSiteCategoryContent
            case .login:
                return UserText.brokenSiteCategoryLogin
            case .unsupported:
                return UserText.brokenSiteCategoryUnsupported
            case .other:
                return UserText.brokenSiteCategoryOther
            }
        }
    }
}
