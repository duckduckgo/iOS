//
//  SyncWarningMessageView.swift
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

struct SyncWarningMessageView: View {
    let title: String
    let message: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?

    init(title: String, message: String, buttonTitle: String? = nil, buttonAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text("⚠️ " + title).daxBodyBold()
                Text(message).daxBodyRegular()
            }
            if let buttonTitle, let buttonAction {
                Button(buttonTitle, action: buttonAction)
            }
        }
    }
}
