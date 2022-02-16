//
//  HomeMessageStorage.swift
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

import Core

struct HomeMessageStorage {
    
    private let variantManager: VariantManager?
    
    init(variantManager: VariantManager? = nil) {
        self.variantManager = variantManager
    }
    
    var messagesToBeShown: [HomeMessage] {
        var messages = [HomeMessage]()
        if shouldShowWidgetEducation {
            messages.append(.widgetEducation)
        }
        return messages
    }
    
    // MARK: - Widget Education
    
    @UserDefaultsWrapper(key: .homeWidgetEducationMessageDismissed, defaultValue: false)
    private var widgetEducationMessageDismissed: Bool
    
    mutating func hideWidgetEducation() {
        widgetEducationMessageDismissed = true
    }
    
    private var shouldShowWidgetEducation: Bool {
        guard #available(iOS 14, *), let variantManager = variantManager else { return false }
        let isFeatureSupported = variantManager.isSupported(feature: .widgetEducation)
        return isFeatureSupported && !widgetEducationMessageDismissed
    }
}
