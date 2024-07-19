//
//  AnimatableTypingText.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import Core
import Combine

// MARK: - View

struct AnimatableTypingText: View {
    private let text: String
    private var startAnimating: Binding<Bool>
    private var onTypingFinished: (() -> Void)?

    @StateObject private var model: AnimatableTypingTextModel

    init(
        _ text: String,
        startAnimating: Binding<Bool> = .constant(true),
        onTypingFinished: (() -> Void)? = nil
    ) {
        self.text = text
        _model = StateObject(wrappedValue: AnimatableTypingTextModel(text: text, onTypingFinished: onTypingFinished))
        self.startAnimating = startAnimating
        self.onTypingFinished = onTypingFinished
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .visibility(.invisible)

            Text(AttributedString(model.typedAttributedText))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: startAnimating.wrappedValue, perform: { shouldAnimate in
            if shouldAnimate {
                model.startAnimating()
            } else {
                model.stopAnimating()
            }
        })
        .onAppear {
            if startAnimating.wrappedValue {
                model.startAnimating()
            }
        }
    }
}

// MARK: - Model

final class AnimatableTypingTextModel: ObservableObject {
    private var timer: TimerInterface?

    @Published private(set) var typedAttributedText: NSAttributedString = .init(string: "")

    private var typingIndex = 0
    private var textTypedSoFar: String = ""
    private let text: String
    private let onTypingFinished: (() -> Void)?
    private let timerFactory: TimerCreating

    init(text: String, onTypingFinished: (() -> Void)?, timerFactory: TimerCreating = TimerFactory()) {
        self.text = text
        self.onTypingFinished = onTypingFinished
        self.timerFactory = timerFactory
    }

    func startAnimating() {
        timer = timerFactory.makeTimer(withTimeInterval: 0.02, repeats: true, block: { [weak self] timer in
            guard timer.isValid else { return }
            self?.handleTimerEvent()
        })
    }

    func stopAnimating() {
        timer?.invalidate()
        timer = nil

        stopTyping()
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    private func handleTimerEvent() {
        if textTypedSoFar == text {
            onTypingFinished?()
            stopAnimating()
            return
        }

        showCharacter()
    }

    private func stopTyping() {
        typedAttributedText = NSAttributedString(string: text)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.onTypingFinished?()
        }
    }

    private func showCharacter() {

        func attributedTypedString(forTypedChars typedChars: [String.Element]) -> NSAttributedString {
            let chars = Array(text)
            let untypedChars = chars[typedChars.count ..< chars.count]
            let combined = NSMutableAttributedString(string: String(typedChars))
            combined.append(NSAttributedString(string: String(untypedChars), attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.clear
            ]))

            return combined
        }

        let chars = Array(text)
        typingIndex = min(typingIndex + 1, chars.count)
        let typedChars = Array(chars[0 ..< typingIndex])
        textTypedSoFar = String(typedChars)
        let attributedString = attributedTypedString(forTypedChars: typedChars)
        typedAttributedText = attributedString
    }

}
