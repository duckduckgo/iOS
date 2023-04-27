//
//  AppTPActivityIconView.swift
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

struct AppTPActivityIconView: View {
    
    let trackerImage: TrackerEntityRepresentable
    let blocked: Bool
    
    var body: some View {
        ZStack {
            HStack {
                switch trackerImage {
                case .svg(let image):
                    Image(uiImage: image)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Const.Size.iconWidth, height: Const.Size.iconWidth)

                case .view(let iconData):
                    GenericIconView(trackerLetter: iconData.trackerLetter,
                                    trackerColor: iconData.trackerColor)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Image(blocked ? "AppTPBlockedTracker" : "AppTPAllowedTracker")
                        .resizable()
                        .frame(width: Const.Size.statusWidth, height: Const.Size.statusWidth)
                    
                    Spacer()
                }
                .padding(.top, Const.Size.statusVerticalPaddig)
                
                Spacer()
            }
        }
        .frame(width: Const.Size.viewWidth)
    }
}

private enum Const {
    enum Size {
        static let iconWidth: CGFloat = 25
        static let statusWidth: CGFloat = 18
        static let statusVerticalPaddig: CGFloat = 19
        static let viewWidth: CGFloat = 40
    }
}
