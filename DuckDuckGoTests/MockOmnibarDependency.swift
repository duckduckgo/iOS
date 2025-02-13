//
//  MockOmnibarDependency.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import AIChat
import Foundation
import BrowserServicesKit
@testable import DuckDuckGo

struct MockOmnibarDependency: OmnibarDependencyProvider {
    var voiceSearchHelper: VoiceSearchHelperProtocol
    var featureFlagger: FeatureFlagger
    var aiChatSettings: AIChatSettingsProvider

    init(voiceSearchHelper: VoiceSearchHelperProtocol = MockVoiceSearchHelper(),
         featureFlagger: FeatureFlagger = MockFeatureFlagger(),
         aiChatSettings: AIChatSettingsProvider = MockAIChatSettingsProvider() ) {
        self.voiceSearchHelper = voiceSearchHelper
        self.featureFlagger = featureFlagger
        self.aiChatSettings = aiChatSettings
    }
}
