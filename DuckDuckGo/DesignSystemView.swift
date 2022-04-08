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
    
    private let redColors: [Color] = [.red100,
                                      .red90,
                                      .red80,
                                      .red70,
                                      .red60,
                                      .redBase,
                                      .red40,
                                      .red30,
                                      .red20,
                                      .red10,
                                      .red0]
    
    private let blueColors: [Color] = [.blue100,
                                       .blue90,
                                       .blue80,
                                       .blue70,
                                       .blue60,
                                       .blueBase,
                                       .blue40,
                                       .blue30,
                                       .blue20,
                                       .blue10,
                                       .blue0,
                                       .deprecatedBlue]
    
    private var backgroundColor: Color {
        if #available(iOS 15.0, *) {
            return Color(uiColor: .systemGroupedBackground)
        } else {
            return Color.white
        }
    }
    
    var body: some View {
        
       
        
        VStack {
            List {
                colorCell(name: "Red", colors: redColors, circleColor: .redBase)
                colorCell(name: "Blue", colors: blueColors, circleColor: .blueBase)
            }
            VStack {
                Button {
                    print("Primary Button")
                } label: {
                    Text("Primary Button")
                }.buttonStyle(PrimaryButtonStyle())
                
                Button {
                    print("test2")
                } label: {
                    Text("Secondary Button")
                }.buttonStyle(SecondaryButtonStyle())
                
                Button {
                    print("test2")
                } label: {
                    Text("Ghost Button")
                }.buttonStyle(GhostButtonStyle())
            }
            .padding()
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
