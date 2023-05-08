//
//  AppTPHomeView.swift
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

struct AppTPHomeView: View {
    
    var countText: some View {
        Text("App Tracking Protection blocked ")
        + Text("123 tracking attempts")
            .fontWeight(.semibold)
        + Text(" in your apps today.")
    }
    
    var body: some View {
        HStack(spacing: Const.Spacing.imageAndTitle) {
            countText
                .font(Font(uiFont: Const.Font.text))
                .lineSpacing(Const.Spacing.line)
            
            Image("AppTPEmptyEnabled")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
        }
        .multilineTextAlignment(.leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: Const.Radius.corner)
                        .fill(Color.background)
                        .shadow(color: Color.shadow,
                                radius: Const.Radius.shadow,
                                x: 0,
                                y: Const.Offset.shadowVertical))
    }
}

private extension Color {
    static let background = Color("HomeMessageBackgroundColor")
    static let shadow = Color("HomeMessageShadowColor")
}

private enum Const {
    enum Font {
        static let text = UIFont.appFont(ofSize: 15)
    }
    
    enum Radius {
        static let shadow: CGFloat = 3
        static let corner: CGFloat = 8
    }
    
    enum Spacing {
        static let imageAndTitle: CGFloat = 4
        static let line: CGFloat = 4
    }
    
    enum Offset {
        static let shadowVertical: CGFloat = 2
    }
}

struct AppTPHomeView_Previews: PreviewProvider {
    static var previews: some View {
        AppTPHomeView()
    }
}
