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
    var isVoiceSearchEnabled: Bool { get }
    
    func enableVoiceSearch(_ enable: Bool)
}

class VoiceSearchHelper: VoiceSearchHelperProtocol {
    private let speechRecognizer = SpeechRecognizer()
    
    var isVoiceSearchEnabled: Bool {
        isSpeechRecognizerAvailable && AppDependencyProvider.shared.appSettings.voiceSearchEnabled
    }
    
    private(set) var isSpeechRecognizerAvailable: Bool = false {
        didSet {
            notifyAvailabilityChange()
        }
    }
    
    init() {
#if targetEnvironment(simulator)
            isSpeechRecognizerAvailable = true
#else
            speechRecognizer.delegate = self
            isSpeechRecognizerAvailable = speechRecognizer.isAvailable
#endif
    }
    
    func enableVoiceSearch(_ enable: Bool) {
        AppDependencyProvider.shared.appSettings.voiceSearchEnabled = enable
        notifyAvailabilityChange()
    }
    
    private func notifyAvailabilityChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .speechRecognizerDidChangeAvailability, object: self)
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
