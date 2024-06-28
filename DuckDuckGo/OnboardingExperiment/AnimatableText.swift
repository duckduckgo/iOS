//
//  AnimatableText.swift
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

#if canImport(UIKit)
typealias PlatformColor = UIColor
#elseif canImport(AppKit)
typealias PlatformColor = NSColor
#endif

struct AnimatableText: View {
    private let text: String
    private let typingDisabled: Bool
    private var onTypingFinished: (() -> Void)?

    @State private var typingIndex = 0
    @State private var typedText = "" {
        didSet {
            guard #available(macOS 12, *) else { return }
            let chars = Array(text)
            let untypedChars = chars[Array(typedText).count ..< chars.count]
            let combined = NSMutableAttributedString(string: typedText)
            combined.append(NSAttributedString(string: String(untypedChars), attributes: [
                NSAttributedString.Key.foregroundColor: PlatformColor.clear
            ]))
            attributedTypedText = combined
        }
    }

    @State private var skipTypingRequested: Bool = false
    @State private var timer = Timer.publish(every: 0.02, tolerance: 0, on: .main, in: .default, options: nil).autoconnect()
    @State private var attributedTypedText = NSAttributedString(string: "")

    init(_ text: String, typingDisabled: Bool = false, onTypingFinished: (() -> Void)? = nil) {
        self.text = text
        self.typingDisabled = typingDisabled
        self.onTypingFinished = onTypingFinished
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .visibility(.invisible)

            if #available(iOS 15, macOS 12, *) {
                Text(AttributedString(attributedTypedText))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(typedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onReceive(timer) { _ in
            handleTimerEvent()
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }

    }

    private func handleTimerEvent() {
        if typingDisabled {
            print("TIMER FIRED - DISABLED")
            typedText = text
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in onTypingFinished?() })
            timer.upstream.connect().cancel()
            return
        } else if skipTypingRequested {
            print("TIMER FIRED - SKIP REQUEST")
            typedText = text
        }

        if typedText == text {
            print("TIMER FIRED - FINISHED")
            onTypingFinished?()
            timer.upstream.connect().cancel()
            return
        }

        print("TIMER FIRED - TYPING CHAR")
        let chars = Array(text)
        typingIndex = min(typingIndex + 1, chars.count)
        let typedChars = chars[0 ..< typingIndex]
        typedText = String(typedChars)
    }

}

// https://swiftuirecipes.com/blog/how-to-hide-a-swiftui-view-visible-invisible-gone
public enum ViewVisibility: CaseIterable {

    case visible, // view is fully visible
         invisible, // view is hidden but takes up space
         gone // view is fully removed from the view hierarchy

}

public extension View {

    // https://swiftuirecipes.com/blog/how-to-hide-a-swiftui-view-visible-invisible-gone
    @ViewBuilder func visibility(_ visibility: ViewVisibility) -> some View {
        if visibility != .gone {
            if visibility == .visible {
                self
            } else {
                hidden()
            }
        }
    }

}
