//
//  MockVoiceSearchHelper.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class MockVoiceSearchHelper: VoiceSearchHelperProtocol {
    var isVoiceSearchEnabled: Bool
    var isSpeechRecognizerAvailable: Bool

    func enableVoiceSearch(_ enable: Bool) {}
    
    init(isSpeechRecognizerAvailable: Bool = true, voiceSearchEnabled: Bool = true) {
        self.isSpeechRecognizerAvailable = isSpeechRecognizerAvailable
        self.isVoiceSearchEnabled = voiceSearchEnabled
        
        if !isSpeechRecognizerAvailable {
            self.isVoiceSearchEnabled = false
        }
    }
}
