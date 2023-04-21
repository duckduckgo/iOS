//
//  AppTPManageTrackerCell.swift
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

struct AppTPManageTrackerCell: View {
    
    @State var isBlocking: Bool
    let tracker: ManagedTrackerRepresentable
    let imageCache: AppTrackerImageCache
    let showDivider: Bool
    
    let onToggleTracker: (String, Bool) -> Void
    
    init(tracker: ManagedTrackerRepresentable, imageCache: AppTrackerImageCache,
         showDivider: Bool, onToggleTracker: @escaping (String, Bool) -> Void) {
        self.tracker = tracker
        self.onToggleTracker = onToggleTracker
        self.imageCache = imageCache
        self.showDivider = showDivider
        
        _isBlocking = .init(initialValue: tracker.blocking)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                let trackerRep = imageCache.loadTrackerImage(for: tracker.trackerOwner)
                switch trackerRep {
                case .svg(let image):
                    Image(uiImage: image)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Const.Size.iconWidth, height: Const.Size.iconWidth)

                case .view(let iconData):
                    GenericIconView(trackerLetter: iconData.trackerLetter,
                                    trackerColor: iconData.trackerColor)
                }
                
                
                Toggle(isOn: $isBlocking) {
                    Text(tracker.domain)
                        .font(Font(uiFont: Const.Font.info))
                        .foregroundColor(.infoText)
                }
                .toggleStyle(SwitchToggleStyle(tint: .toggleTint))
                .onChange(of: isBlocking) { value in
                    onToggleTracker(tracker.domain, value)
                }
            }
            .padding(.horizontal)
            .frame(height: Const.Size.standardCellHeight)
            
            if showDivider {
                Divider()
            }
        }
    }
}

private enum Const {
    enum Font {
        static let info = UIFont.appFont(ofSize: 16)
    }
    
    enum Size {
        static let standardCellHeight: CGFloat = 44
        static let iconWidth: CGFloat = 25
    }
}

private extension Color {
    static let infoText = Color("AppTPDomainColor")
    static let toggleTint = Color("AppTPToggleColor")
}
