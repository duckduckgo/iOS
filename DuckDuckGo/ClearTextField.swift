//
//  ClearTextField.swift
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

struct ClearTextField: View {
    var placeholderText: String
    @Binding var text: String
    var autoCapitalizationType: UITextAutocapitalizationType = .none
    var disableAutoCorrection = true
    var keyboardType: UIKeyboardType = .default
    var secure = false

    @State private var closeButtonVisible = false

    var body: some View {
        HStack {
            TextField(placeholderText, text: $text) { editing in
                closeButtonVisible = editing
            } onCommit: {
                closeButtonVisible = false
            }
            .autocapitalization(autoCapitalizationType)
            .disableAutocorrection(disableAutoCorrection)
            .keyboardType(keyboardType)
            .label4Style(design: secure && text.count > 0 ? .monospaced : .default)

            Spacer()
            Image("Clear-16")
                .opacity(closeButtonOpacity)
                .onTapGesture { self.text = "" }
        }
    }

    private var closeButtonOpacity: Double {
        if text == "" || !closeButtonVisible {
            return 0
        }
        return 1
    }
}
