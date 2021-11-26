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
    var privacyAlertWasConfirmed: Bool { get }
    func markPrivacyAlertAsConfirmed()
}

class VoiceSearchHelper: VoiceSearchHelperProtocol {
    private(set) var isSpeechRecognizerAvailable: Bool = false
    private var variantManager: VariantManager?

    @UserDefaultsWrapper(key: .voiceSearchPrivacyAlertWasConfirmed, defaultValue: false)
    private(set) var privacyAlertWasConfirmed: Bool
    
    init(_ variantManager: VariantManager? = nil) {
        self.variantManager = variantManager
        
        updateFlag()
        
        NotificationCenter.default.addObserver(forName: NSLocale.currentLocaleDidChangeNotification, object: nil, queue: nil) { [weak self] _ in
            self?.updateFlag()
        }
    }
    
    func markPrivacyAlertAsConfirmed() {
        privacyAlertWasConfirmed = true
    }
    
    private func updateFlag() {
#if targetEnvironment(simulator)
        isSpeechRecognizerAvailable = true
#else
        isSpeechRecognizerAvailable = SpeechRecognizer().isAvailable
        
        #warning("Enable before release")
        // We don't want to override the flag in case there's no SpeechRecognizer available for this device
//        if let variantManager = variantManager, isSpeechRecognizerAvailable {
//            isSpeechRecognizerAvailable = variantManager.isSupported(feature: .voiceSearch)
//        }
#endif
    }
}
