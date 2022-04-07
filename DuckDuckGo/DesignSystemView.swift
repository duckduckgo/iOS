//
//  DesignSystemView.swift
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
import DuckUI

struct DesignSystemView: View {
    private let redColors = [DuckColor.red100,
                             DuckColor.red90,
                             DuckColor.red80,
                             DuckColor.red70,
                             DuckColor.red60,
                             DuckColor.redBase,
                             DuckColor.red40,
                             DuckColor.red30,
                             DuckColor.red20,
                             DuckColor.red10,
                             DuckColor.red0]
    
    var body: some View {
        ScrollView {
            ForEach(redColors, id: \.self) { color in
                ZStack {
                    Rectangle()
                        .foregroundColor(color)
                        .frame(height: 50)
                    Text(color.self.description)
                }

            }
        }
    }
}

struct DesignSystemView_Previews: PreviewProvider {
    static var previews: some View {
        DesignSystemView()
    }
}
