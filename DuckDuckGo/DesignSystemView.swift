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
    @State var selectedColors: [Color]?
    
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
    
    private let blueColors = [DuckColor.blue100,
                              DuckColor.blue90,
                              DuckColor.blue80,
                              DuckColor.blue70,
                              DuckColor.blue60,
                              DuckColor.blueBase,
                              DuckColor.blue40,
                              DuckColor.blue30,
                              DuckColor.blue20,
                              DuckColor.blue10,
                              DuckColor.blue0]
    
    
    var body: some View {
        List {
            colorCell(name: "Red", colors: redColors, circleColor: DuckColor.redBase)
            colorCell(name: "Blue", colors: blueColors, circleColor: DuckColor.blueBase)
        }
    }
    
    private func colorCell(name: String, colors: [Color], circleColor: Color) -> some View {
        NavigationLink(destination: colorsView(colors)) {
            HStack {
                Text(name)
                Spacer()
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(circleColor)
            }
        }
    }
    
    private func colorsView(_ colors: [Color]) -> some View {
        ScrollView {
            ForEach(colors, id: \.self) { color in
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
