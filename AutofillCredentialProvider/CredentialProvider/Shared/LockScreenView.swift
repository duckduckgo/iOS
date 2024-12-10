//
//  LockScreenView.swift
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
import DesignResourcesKit

struct LockScreenView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Image(.autofillLock)
                    .position(x: geometry.size.width / 2,
                              y: shouldCenterVerticallyInLandscape(on: geometry) ? geometry.size.height / 2 : geometry.size.height * 0.8)
            }
        }
        .background(Color(designSystemColor: .background))
    }
    
    private func shouldCenterVerticallyInLandscape(on geometry: GeometryProxy) -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone && geometry.size.width > geometry.size.height
    }
}

#Preview {
    LockScreenView()
}
