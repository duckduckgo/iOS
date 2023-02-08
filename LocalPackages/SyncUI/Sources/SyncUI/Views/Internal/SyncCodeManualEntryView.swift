//
//  SyncCodeManualEntryView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import DuckUI

struct SyncCodeManualEntryView: View {

    @ObservedObject var model: SyncCodeCollectionViewModel

    @State var isEditingCode = false

    @ViewBuilder
    func pasteButton() -> some View {
        Button(action: model.pasteCode) {
            Label("Paste", image: "SyncPaste")
        }
    }

    @ViewBuilder
    func codeEntrySection() -> some View {
        ZStack {
            VStack {
                HStack { Spacer() }
                Spacer()
            }

            RoundedRectangle(cornerRadius: 8).foregroundColor(.white.opacity(0.09))

            VStack(spacing: 0) {
                Spacer()

                if let code = model.manuallyEnteredCode {

                    Text(code)
                        .kerning(3)
                        .lineLimit(Constants.codeLines)
                        .monospaceSystemFont(ofSize: Constants.codeFontSize)
                        .padding()

                    Spacer()

                }

                if model.isValidating {
                    HStack(spacing: 4) {
                        SwiftUI.ProgressView()
                        Text("Validating code")
                            .foregroundColor(.white.opacity(0.36))
                    }
                } else if let error = model.codeError {
                    HStack {
                        Image("SyncAlert")

                        Text("\(error)")
                            .foregroundColor(.white.opacity(0.36))
                    }
                } else {

                    instructions()

                    Spacer()
                }

                pasteButton()
                    .buttonStyle(PasteButtonStyle())
                    .padding(.vertical, 20)

            }
        }
        .frame(maxWidth: 350, maxHeight: 350)
        .padding()
    }

    @ViewBuilder
    func instructions() -> some View {
        Text("Enter the code on your recovery PDF, or connected device, above to recover your synced data.")
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .foregroundColor(.white.opacity(0.6))
            .padding()
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                codeEntrySection()
                Spacer()
            }
            .frame(maxWidth: Constants.maxWidth, alignment: .center)
        }
        .padding(.horizontal, 20)
        .navigationTitle("Manually Enter Code")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                pasteButton()
                    .foregroundColor(.white)
            }
        }
        .modifier(SyncBackButtonModifier())
        .ignoresSafeArea(.keyboard)
    }

}

private extension View {

    @ViewBuilder
    func monospaceSystemFont(ofSize size: Double) -> some View {
        if #available(iOS 15.0, *) {
            font(.system(size: size).monospaced())
        } else {
            font(.system(size: size))
        }
    }

}

private struct CodeEntryView: UIViewRepresentable {

    @Binding var focused: Bool
    @Binding var text: String?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .monospacedSystemFont(ofSize: 20, weight: .regular)
        textView.adjustsFontForContentSizeCategory = true
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text?.groups(ofSize: 4) ?? ""
    }

    class Coordinator: NSObject, UITextViewDelegate {

        let view: CodeEntryView

        init(_ view: CodeEntryView) {
            self.view = view
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            view.focused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            view.focused = false
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
                textView.resignFirstResponder() // uncomment this to close the keyboard when return key is pressed
                return false
            }
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                view.text = nil
            } else {
                let text = textView.text.groups(ofSize: 4)
                view.text = text
                textView.text = text
            }
        }

    }

}

private extension String {
    
    func chunks(ofSize: Int) -> [String] {
        let chunks = stride(from: 0, to: self.count, by: ofSize).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: ofSize, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
        return chunks
    }

    func groups(ofSize: Int) -> String {
        return components(separatedBy: .whitespaces).joined().chunks(ofSize: 4).joined(separator: " ")
    }

}

struct PasteButtonStyle: ButtonStyle {

    private var backgroundColor: Color {
        .deprecatedBlue
    }

    private var foregroundColor: Color {
        .black
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(0.7) : foregroundColor.opacity(1))
            .padding(.horizontal)
            .frame(height: 44)
            .background(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor.opacity(1))
            .cornerRadius(8)
            .font(.system(size: 15, weight: .semibold))

    }

}
