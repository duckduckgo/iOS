//
//  VoiceSearchHelper.swift
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

/*
 Instead of initializing SpeechRecognizer to check its availability
 use VoiceSearchHelper instead since it keeps track of the current availability without extra initializations
 */
class VoiceSearchHelper {
    static let shared = VoiceSearchHelper()
    var isSpeechRecognizerAvailable: Bool = false
    
    @UserDefaultsWrapper(key: .voiceSearchPrivacyAlertWasConfirmed, defaultValue: false)
    var voiceSearchPrivacyAlertWasConfirmed: Bool

    private init() {
        updateFlag()
        
        NotificationCenter.default.addObserver(forName: NSLocale.currentLocaleDidChangeNotification, object: nil, queue: nil) { [weak self] _ in
            self?.updateFlag()
        }
    }
    
    private func updateFlag() {
        isSpeechRecognizerAvailable = SpeechRecognizer().isAvailable
    }
}
