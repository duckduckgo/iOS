//
//  GlassySegmentedControl.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
struct GlassySegmentedControl: View {
    @Binding var selectedOption: Int
    let options = ["Search", "Duck.ai"]

    private enum Constants {
        static let cornerRadius: CGFloat = 20
        static let buttonHeight: CGFloat = 50
        static let padding: CGFloat = 4
        static let shadowRadius: CGFloat = 5
        static let largeShadowRadius: CGFloat = 10
        static let shadowOffset: CGFloat = 3
        static let largeShadowOffset: CGFloat = 5
        static let animationDuration: Double = 0.3
        static let springDampingFraction: Double = 0.7
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                backgroundView
                slidingSelectionView(in: geometry)
                buttonsView
            }
        }
        .frame(height: Constants.buttonHeight)
        .overlay(borderOverlay)
        .padding()
    }

    private var backgroundView: some View {
        BlurView(style: .systemUltraThinMaterialDark)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }

    private func slidingSelectionView(in geometry: GeometryProxy) -> some View {
        let optionWidth = geometry.size.width / CGFloat(options.count)
        return RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .fill(Colors.innerCircle.opacity(0.6))
            .shadow(color: Color.black.opacity(0.5), radius: Constants.shadowRadius, x: -Constants.shadowOffset, y: -Constants.shadowOffset)
            .shadow(color: Color.black.opacity(0.2), radius: Constants.shadowRadius, x: Constants.shadowOffset, y: Constants.shadowOffset)
            .frame(width: optionWidth)
            .offset(x: CGFloat(selectedOption) * optionWidth)
            .animation(.spring(response: Constants.animationDuration, dampingFraction: Constants.springDampingFraction), value: selectedOption)
    }

    private var buttonsView: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                button(for: index)
            }
        }
        .padding(Constants.padding)
    }

    private func button(for index: Int) -> some View {
        Button(action: { selectedOption = index }) {
            HStack {
                Spacer()
                Image(index == 0 ? "DuckDuckGo-Silhouette-OnDark-24" : "AIChat-24")
                Text(options[index])
                Spacer()
            }
            .foregroundColor(selectedOption == index ? .white : .gray)
            .animation(.easeInOut, value: selectedOption)
        }
        .frame(maxHeight: .infinity)
        .background(Color.clear)
        .contentShape(Rectangle())

    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
    }
    private struct Colors {
        static let innerCircle = Color(UIColor(hex: "3969EF"))
        static let footerText = Color(UIColor(hex: "888888"))
        static let outerCircle = Color(UIColor(hex: "7295F6")).opacity(0.2)
        static let cancelButton = Color("VoiceSearchCancelColor")
        static let speechFeedback = Color("VoiceSearchSpeechFeedbackColor")
    }

}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
