//
//  GenericIconView.swift
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

struct GenericIconView: View {
    
    let trackerLetter: String
    let trackerColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(trackerColor)
            
            Text(trackerLetter)
                .font(Font(uiFont: Const.Font.sectionHeader))
                .foregroundColor(.white)
                .padding(.top, 1)
        }
        .frame(width: 24)
    }
}

private enum Const {
    enum Font {
        static let sectionHeader = UIFont.semiBoldAppFont(ofSize: 16)
    }
}
