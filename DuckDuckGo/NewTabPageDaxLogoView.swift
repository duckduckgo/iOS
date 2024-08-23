//
//  NewTabPageDaxLogoView.swift
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

struct NewTabPageDaxLogoView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(.home)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 96)
            Image(.textDuckDuckGo)
        }
    }
}

#Preview {
    NewTabPageDaxLogoView()
}
