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
import SVGView

struct AppTPActivityIconView: View {
    
    let trackerImage: Data
    let blocked: Bool
    
    var body: some View {
        ZStack {
            HStack {
                SVGView(data: trackerImage)
                    .frame(width: 24, height: 24)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Image(blocked ? "AppTPBlockedTracker" : "AppTPAllowedTracker")
                        .resizable()
                        .frame(width: 18, height: 18)
                    
                    Spacer()
                }
                .padding(.top, 19)
                
                Spacer()
            }
        }
        .frame(width: 40)
    }
}

struct AppTPActivityIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppTPActivityIconView(
            trackerImage: AppTrackerImageCache().loadTrackerImage(for: "Google LLC"),
            blocked: true
        )
    }
}
