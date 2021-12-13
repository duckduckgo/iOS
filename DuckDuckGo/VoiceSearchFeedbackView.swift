//
//  VoiceSearchFeedbackView.swift
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

import SwiftUI

struct VoiceSearchFeedbackView: View {
    @ObservedObject var speechModel: VoiceSearchFeedbackViewModel

    var body: some View {
        VStack {
           cancelButton
            Spacer()
            Text(speechModel.speechFeedback)
                .multilineTextAlignment(.center)
                .foregroundColor(Colors.speechFeedback)
                .padding()
                .padding(.bottom, Padding.recognizedTextBottom)
            ZStack {
                outerCircle
                innerCircle
                micImage
            }.padding(.bottom, Padding.microphoneCircleBottom)
        }
        .onAppear {
            if #available(iOS 15, *) {
                speechModel.startSpeechRecognizer()
            }
            speechModel.startSilenceAnimation()
        }.onDisappear {
            speechModel.stopSpeechRecognizer()
        }
    }
}

struct VoiceSearchFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.self) {
                VoiceSearchFeedbackView(speechModel: VoiceSearchFeedbackViewModel(speechRecognizer: MockSpeechRecognizer()))
                    .preferredColorScheme($0)
            }
        }
    }
}

// MARK: - Animation

extension VoiceSearchFeedbackView {
    
    private var outerCircleScale: CGFloat {
        switch speechModel.animationType {
        case .pulse(let scale):
            return scale
        case .speech(let volume):
            return volume
        }
    }
    
    private var outerCircleAnimation: Animation {
        switch speechModel.animationType {
        case .pulse:
            return .easeInOut(duration: AnimationDuration.pulse).repeatForever()
        case .speech:
            return .linear(duration: AnimationDuration.speech)
        }
    }
}

// MARK: - Views

extension VoiceSearchFeedbackView {
    
    private var cancelButton: some View {
        HStack {
            Button {
                speechModel.cancel()
            } label: {
                Text(UserText.voiceSearchCancelButton)
                    .foregroundColor(Colors.cancelButton)
            }.alignmentGuide(.leading) { d in d[.leading] }
            .padding()
            Spacer()
        }
    }
    
    private var innerCircle: some View {
        Button {
            speechModel.finish()
        } label: {
            Circle()
                .foregroundColor(Colors.innerCircle)
                .frame(width: CircleSize.inner.width, height: CircleSize.inner.height, alignment: .center)
        }
    }
    
    private var micImage: some View {
        Image(micIconName)
            .resizable()
            .renderingMode(.template)
            .frame(width: micSize.width, height: micSize.height)
            .foregroundColor(.white)
    }
    
    private var outerCircle: some View {
        Circle()
            .foregroundColor(Colors.outerCircle)
            .frame(width: CircleSize.outer.width,
                   height: CircleSize.outer.height,
                   alignment: .center)
            .scaleEffect(outerCircleScale)
            .animation(outerCircleAnimation, value: outerCircleScale)
    }
    
}

// MARK: - Constants

extension VoiceSearchFeedbackView {
    private var micIconName: String {
        "MicrophoneSolid"
    }
    
    private var micSize: CGSize {
        CGSize(width: 32, height: 32)
    }
    
    private struct Padding {
        static let microphoneCircleBottom: CGFloat = 125
        static let recognizedTextBottom: CGFloat = 40
    }
    
    private struct CircleSize {
        static let inner = CGSize(width: 56, height: 56)
        static let outer = CGSize(width: 120, height: 120)
    }
    
    private struct Colors {
        static let innerCircle = Color(UIColor(hex: "3969EF"))
        static let outerCircle = Color(UIColor(hex: "7295F6")).opacity(0.2)
        static let cancelButton = Color("VoiceSearchCancelColor")
        static let speechFeedback = Color("VoiceSearchSpeechFeedbackColor")
    }
    
    private struct AnimationDuration {
        static let pulse = 2.5
        static let speech = 0.1
    }
}
