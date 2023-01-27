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

    enum FocusField: Hashable {
        case field
    }

    @ObservedObject var model: SyncCodeCollectionViewModel

    @State var isEditingCode = false

    @ViewBuilder
    func codeEntryField() -> some View {
        ZStack {


            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.white.opacity(0.09))

                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.24))

                ZStack(alignment: .topLeading) {
                    CodeEntryView(focused: $isEditingCode, text: $model.manuallyEnteredCode)

                    if !isEditingCode && model.manuallyEnteredCode == nil {
                        Text("Recovery Code")
                            .foregroundColor(.primary.opacity(0.36))
                    }
                }
                .padding()
            }
            .padding(.horizontal)

        }
        .frame(width: 310, height: 150)
        .padding()

    }

    @ViewBuilder
    func codeEntrySection(size: CGFloat) -> some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.white.opacity(0.09))

                VStack {

                    Spacer()

                    codeEntryField()

                    Spacer()

                    Button(action: model.pasteCode) {
                        Label("Paste", image: "SyncPaste")
                    }
                    .buttonStyle(SyncLabelButtonStyle())
                    .padding(.bottom, 20)

                }
            }.padding(.horizontal)
        }
        .frame(width: size, height: size)
    }

    var body: some View {
        GeometryReader { g in
            ZStack {
                VStack {

                    codeEntrySection(size: g.size.width)

                    if !isEditingCode {
                        VStack {
                            Text("Enter the code on your recovery PDF, or connected device, above to recover your synced data.")
                                .multilineTextAlignment(.center)

                            Spacer()

                            Button("Submit", action: {})
                                .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding()
                        .padding(.top, 32)
                    }
                }
                .navigationTitle("Manually Enter Code")
            }
            .background(Color.white.opacity(0.001))
            .modifier(SyncBackButtonModifier())
            // This are kinda hacky ways to hide the keyboard
            .gesture(DragGesture().onChanged({ _ in
                print("onTapGesture")
                UIApplication.shared.endEditing()
            }))
            .onTapGesture {
                print("onTapGesture")
                UIApplication.shared.endEditing()
            }
        }
    }

}

struct CodeEntryView: UIViewRepresentable {

    @Binding var focused: Bool
    @Binding var text: String?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
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

        func textViewDidChange(_ textView: UITextView) {
            print(#function, textView.text ?? "nil")
            if textView.text.trimmingWhitespace().isEmpty {
                view.text = nil
            } else {
                let text = textView.text.groups(ofSize: 4)
                view.text = text
                textView.text = text
            }
        }

    }

}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension String {
    
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
