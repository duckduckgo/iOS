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

    var body: some View {
        GeometryReader { g in
            VStack {
                ZStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.white.opacity(0.09))

                        VStack {

                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.white.opacity(0.09))

                                ZStack(alignment: .topLeading) {
                                    CodeEntryView(focused: $isEditingCode)

                                    if !isEditingCode {
                                        Text("Recovery Code")
                                    }
                                }

                            }
                            .padding()

                            Spacer()

                            Button(action: model.pasteCode) {
                                Label("Paste", image: "SyncPaste")
                            }
                            .buttonStyle(PasteButtonStyle())
                            .padding(.bottom)

                        }
                    }.padding()
                }
                .frame(width: g.size.width, height: g.size.width)

                VStack {
                    Text("Enter the code on your recovery PDF, or connected device, above to recover your synced data.")

                    Spacer()

                    Button("Submit", action: {})
                        .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
                .padding(.top, 32)
            }.navigationTitle("Manually Enter Code")
        }
    }

}

struct PasteButtonStyle: ButtonStyle {

    private var backgroundColor: Color {
        .white.opacity(0.18)
    }

    private var foregroundColor: Color {
        .primary
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(0.7) : foregroundColor.opacity(1))
            .padding(.horizontal)
            .frame(height: 40)
            .background(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor.opacity(1))
            .cornerRadius(12)
    }

}

struct CodeEntryView: UIViewRepresentable {

    @Binding var focused: Bool

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {

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

    }

}
