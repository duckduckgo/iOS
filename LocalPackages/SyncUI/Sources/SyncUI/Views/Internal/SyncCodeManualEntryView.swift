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
    func codeEntryField() -> some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                Group {
                    CodeEntryView(focused: $isEditingCode, text: $model.manuallyEnteredCode)

                    if !isEditingCode && model.manuallyEnteredCode == nil {
                        Text("Recovery Code")
                            .foregroundColor(.primary.opacity(0.36))
                    }
                }.padding(4)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.white.opacity(0.09))

                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.24))
                }
            )
        }
        .padding(.horizontal)
        .frame(height: 150)
        .padding(4)

    }

    @ViewBuilder
    func codeEntrySection() -> some View {
        ZStack {
            VStack {
                HStack { Spacer() }
                Spacer()
            }

            RoundedRectangle(cornerRadius: 8).foregroundColor(.white.opacity(0.09))

            VStack(spacing: 20) {
                Spacer()

                codeEntryField()

                Spacer()

                Button(action: model.pasteCode) {
                    Label("Paste", image: "SyncPaste")
                }
                .buttonStyle(SyncLabelButtonStyle())
                .padding(.bottom, 20)
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
    }

    @ViewBuilder
    func button() -> some View {
        Button("Submit", action: model.submitAction)
            .buttonStyle(PrimaryButtonStyle(disabled: !model.canSubmitManualCode))
            .disabled(!model.canSubmitManualCode)
            .padding(.bottom, 20)
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                codeEntrySection()
                instructions()
                Spacer()
                button()
            }
            .frame(maxWidth: SyncUIConstants.maxWidth, alignment: .center)
        }
        .padding(.horizontal, 20)
        .navigationTitle("Manually Enter Code")
        .modifier(SyncBackButtonModifier())
        .ignoresSafeArea(.keyboard)
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
        textView.font = .monospacedSystemFont(ofSize: 18, weight: .regular)
        textView.adjustsFontForContentSizeCategory = true
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        print(#function)
        uiView.text = text?.groups(ofSize: 4) ?? ""
    }

    class Coordinator: NSObject, UITextViewDelegate {

        let view: CodeEntryView

        init(_ view: CodeEntryView) {
            self.view = view
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            print(#function)
            view.focused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            print(#function)
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
            print(#function, textView.text ?? "nil")
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
