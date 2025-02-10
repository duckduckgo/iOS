//
//  VoiceSearchFeedbackViewModel.swift
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
import UIKit

protocol VoiceSearchFeedbackViewModelDelegate: AnyObject {
    func voiceSearchFeedbackViewModel(_ model: VoiceSearchFeedbackViewModel, didFinishQuery query: String?, target: VoiceSearchTarget)
}

class VoiceSearchFeedbackViewModel: ObservableObject {
   
    enum AnimationType {
        case speech(volume: CGFloat)
        case pulse(scale: CGFloat)
    }
    
    private struct AnimationScale {
        static let max: CGFloat = 1.80
        static let pulse: CGFloat = 0.7
    }
    
    @Published private(set) var speechFeedback = " "
    @Published private(set) var animationType: AnimationType = .pulse(scale: 1)

    @UserDefaultsWrapper(key: .voiceSearchTargetPreferences, defaultValue: 0)
    private var targedSelectedOption: Int

    @Published var selectedOption: Int = 0 {
        didSet {
            targedSelectedOption = selectedOption
        }
    }

    weak var delegate: VoiceSearchFeedbackViewModelDelegate?
    private let speechRecognizer: SpeechRecognizerProtocol
    private var isSilent = true
    private let maxWordsCount = 30
    private var recognizedWords: String? {
        didSet {
            if let words = recognizedWords {
                speechFeedback = "\"\(words)\""
            } else {
                speechFeedback = " "
            }
        }
    }

    internal init(speechRecognizer: SpeechRecognizerProtocol) {
        self.speechRecognizer = speechRecognizer
        selectedOption = self.targedSelectedOption
    }

    func startSpeechRecognizer() {
        speechRecognizer.startRecording { [weak self] text, error, speechDidFinish in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.recognizedWords = text
                
                if speechDidFinish || error != nil || self.hasReachedWordLimit(text) {
                    self.finish()
                }
            }
            
        } volumeCallback: { [weak self] volume in
            DispatchQueue.main.async {
                self?.setupAnimationWithVolume(volume)
            }
        }
    }
    
    private func hasReachedWordLimit(_ recognizedText: String?) -> Bool {
        guard let text = recognizedText else { return false }
        return text.split(separator: " ").count >= maxWordsCount
    }
    
    private func setupAnimationWithVolume(_ volume: Float) {
        let isCurrentlySilent = volume <= 0
        // We want to make sure that every detected sound makes the outer circle bigger
        let minScale: CGFloat = 1.2
        
        if !isCurrentlySilent {
            let scaleValue = min(CGFloat(volume) + minScale, AnimationScale.max)
            self.startSpeechAnimation(scaleValue)
        }
        
        if !self.isSilent && isCurrentlySilent {
            self.startSilenceAnimation()
        }
        
        self.isSilent = isCurrentlySilent
    }
    
    func stopSpeechRecognizer() {
        speechRecognizer.stopRecording()
    }
    
    func startSilenceAnimation() {
        self.animationType = .pulse(scale: AnimationScale.pulse)
    }
    
    func startSpeechAnimation(_ scale: CGFloat) {
        self.animationType = .speech(volume: scale)
    }

    var selectedOptionType: VoiceSearchTarget {
        if selectedOption == 0 {
            return .search
        } else {
            return .aiChat
        }
    }
    func cancel() {
        Pixel.fire(pixel: .voiceSearchCancelled)
        delegate?.voiceSearchFeedbackViewModel(self, didFinishQuery: nil, target: selectedOptionType)
    }
    
    func finish() {
        delegate?.voiceSearchFeedbackViewModel(self, didFinishQuery: recognizedWords, target: selectedOptionType)
    }
}
