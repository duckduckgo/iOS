//
//  SpeechFeedbackViewModel.swift
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
import UIKit

protocol SpeechFeedbackViewModelDelegate: AnyObject {
    func speechFeedbackViewModelDidFinish(_ model: SpeechFeedbackViewModel, query: String?)
}

class SpeechFeedbackViewModel: ObservableObject {
   
    enum AnimationType {
        case speech(volume: Double)
        case pulse(scale: Double)
    }
    
    @Published private(set) var speechFeedback = " "
    @Published private(set) var animationType: AnimationType = .pulse(scale: 1)
    weak var delegate: SpeechFeedbackViewModelDelegate?
    private let speechRecognizer: SpeechRecognizerProtocol
    private let maxScale: Double = 1.3
    private let pulseScale: Double = 0.7
    private var recognizedWords: String? = nil {
        didSet {
            if let words = recognizedWords {
                speechFeedback = "\"\(words)\""
            } else {
                speechFeedback = " "
            }
        }
    }
    
    private var isSilent = true {
        didSet {
            if isSilent {
                startSilenceAnimation()
            }
        }
    }

    internal init(speechRecognizer: SpeechRecognizerProtocol = MockSpeechRecognizer()) {
        self.speechRecognizer = speechRecognizer
    }
    
    @available(iOS 15, *)
    func startSpeechRecognizer() {
        speechRecognizer.startRecording { [weak self] text, _, speechDidFinished in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.recognizedWords = text
                
                if speechDidFinished {
                    self.finish()
                }
            }
            
        } volumeCallback: { [weak self] volume in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if volume != 0 {
                    let scaleValue = min(Double(volume) + 1, self.maxScale)
                    self.animationType = .speech(volume: scaleValue)
                }
                
                // Prevent isSilent from being set multiple times
                let hasVolume = volume == 0
                if self.isSilent != hasVolume {
                    self.isSilent = hasVolume
                }
            }
        }
    }
    
    func stopSpeechRecognizer() {
        speechRecognizer.stopRecording()
    }
    
    func startSilenceAnimation() {
        self.animationType = .pulse(scale: pulseScale)
    }
    
    func cancel() {
        delegate?.speechFeedbackViewModelDidFinish(self, query: nil)
    }
    
    func finish() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        self.delegate?.speechFeedbackViewModelDidFinish(self, query: recognizedWords)
    }
    
    deinit {
        print("\(SpeechFeedbackViewModel.self) deinit")
    }
}

struct MockSpeechRecognizer: SpeechRecognizerProtocol {
    var isAvailable: Bool = false
    var isRunning: Bool = false
    static func requestMicAccess(withHandler handler: @escaping (Bool) -> Void) { }
 
    func getVolumeLevel(from channelData: UnsafeMutablePointer<Float>) -> Float {
        return 10
    }
    
    func startRecording(resultHandler: @escaping (String?, Error?, Bool) -> Void, volumeCallback: @escaping (Float) -> Void) { }
    func stopRecording() { }
}
