//
//  HeaderView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import DesignResourcesKit

public struct HeaderView: View {

    public let imageName: String
    public let title: String

    public init(imageName: String, title: String) {
        self.imageName = imageName
        self.title = title
    }

    public var body: some View {
        VStack(spacing: 18) {
            Image(imageName)

            Text(title)
                .daxTitle2()
                .foregroundColor(.waitlistTextPrimary)
                .lineSpacing(6)
                .multilineTextAlignment(.center)
                .fixMultilineScrollableText()
        }
        .padding(.top, 24)
        .padding(.bottom, 12)
    }
}
