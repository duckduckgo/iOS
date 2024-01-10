//
//  PurchaseInProgressView.swift
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

struct PurchaseInProgressView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // TODO: Update colors and design
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .white)
                .opacity(0.0)
                .edgesIgnoringSafeArea(.all)
                .disabled(true)
                        
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? .black : .white)
                    .frame(width: 120, height: 120)
                    .shadow(color: colorScheme == .dark ? .black : .gray30, radius: 10)
                
                SwiftUI.ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(colorScheme == .dark ? .gray30 : .gray70)))
            }
                
        }
    }
}
