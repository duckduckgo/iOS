//
//  PasteCodeView.swift
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
import DesignResourcesKit

public struct PasteCodeView: View {

    static let codeFontSize = 18.0
    static let codeLines = 10

    @ObservedObject var model: ScanOrPasteCodeViewModel

    @State var isEditingCode = false

    public init(model: ScanOrPasteCodeViewModel) {
        self.model = model
    }

    @ViewBuilder
    func pasteButton() -> some View {
        Button(action: model.pasteCode) {
            Label(UserText.pasteButton, image: "SyncPaste")
        }
    }

    @ViewBuilder
    func codeEntrySection() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).foregroundColor(.white.opacity(0.12))

            VStack(spacing: 0) {
                Spacer()

                if let code = model.manuallyEnteredCode {

                    Text(code)
                        .kerning(3)
                        .lineLimit(Self.codeLines)
                        .monospaceSystemFont(ofSize: Self.codeFontSize)
                        .padding()

                    Spacer()

                }

                if model.isValidating {
                    HStack(spacing: 4) {
                        SwiftUI.ProgressView()
                        Text(UserText.manuallyEnterCodeValidatingCodeAction)
                            .foregroundColor(.white.opacity(0.36))
                    }
                    .padding(.horizontal)
                } else if model.invalidCode {
                    HStack {
                        Image("SyncAlert")
                        Text(UserText.manuallyEnterCodeValidatingCodeFailedAction)
                            .foregroundColor(.white.opacity(0.36))
                    }
                    .padding(.horizontal)
                } else {

                    if #available(iOS 15.0, *) {
                        Text(instructionsString)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                    } else {
                        Text(UserText.manuallyEnterCodeInstruction)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                    }

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

    @available(iOS 15, *)
    var instructionsString: AttributedString {
        let baseString = UserText.manuallyEnterCodeInstructionAttributed(syncMenuPath: UserText.syncMenuPath, menuItem: UserText.viewTextCodeMenuItem)
        var instructions = AttributedString(baseString)
        if let range1 = instructions.range(of: UserText.syncMenuPath) {
            instructions[range1].font = .boldSystemFont(ofSize: 16)
        }
        if let range2 = instructions.range(of: UserText.viewTextCodeMenuItem) {
            instructions[range2].font = .boldSystemFont(ofSize: 16)
        }
        return instructions
    }

    @ViewBuilder
    func pastCodeWiewWithNoModifier() -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                codeEntrySection()
                Spacer()
            }
            .frame(maxWidth: Constants.maxFullScreenWidth, alignment: .center)
        }
        .padding(.horizontal, 20)
        .navigationTitle(UserText.manuallyEnterCodeTitle)
        .ignoresSafeArea(.keyboard)
    }

    public var body: some View {
        pastCodeWiewWithNoModifier()
            .modifier(BackButtonModifier())

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
        .blue30
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
            .daxButton()

    }

}
