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

protocol VoiceSearchHelperProtocol {
    var isSpeechRecognizerAvailable: Bool { get }
}

class VoiceSearchHelper: VoiceSearchHelperProtocol {
    private(set) var isSpeechRecognizerAvailable: Bool = false {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .speechRecognizerDidChangeAvailability, object: self)
            }
        }
    }
    
    private let speechRecognizer = SpeechRecognizer()
    
    init() {
        // https://app.asana.com/0/1201011656765697/1201271104639596
        if #available(iOS 15.0, *) {
#if targetEnvironment(simulator)
            isSpeechRecognizerAvailable = true
#else
            speechRecognizer.delegate = self
            isSpeechRecognizerAvailable = speechRecognizer.isAvailable
#endif
        }
    }
}

extension VoiceSearchHelper: SpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SpeechRecognizer, availabilityDidChange available: Bool) {
        // Avoid unnecessary notifications
        if isSpeechRecognizerAvailable != available {
            isSpeechRecognizerAvailable = available
        }
    }
}

extension Notification.Name {
    public static let speechRecognizerDidChangeAvailability = Notification.Name("com.duckduckgo.app.SpeechRecognizerDidChangeAvailability")
}
