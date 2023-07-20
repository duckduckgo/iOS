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
import DesignResourcesKit

struct AppTPManageTrackerCell: View {
    
    @State var isBlocking: Bool
    let trackerDomain: String
    let trackerOwner: String
    let imageCache: AppTrackerImageCache
    let showDivider: Bool
    
    let onToggleTracker: (String, Bool) -> Void
    
    init(trackerDomain: String, trackerBlocked: Bool, trackerOwner: String, imageCache: AppTrackerImageCache,
         showDivider: Bool, onToggleTracker: @escaping (String, Bool) -> Void) {
        self.trackerDomain = trackerDomain
        self.trackerOwner = trackerOwner
        self.onToggleTracker = onToggleTracker
        self.imageCache = imageCache
        self.showDivider = showDivider
        
        _isBlocking = .init(initialValue: trackerBlocked)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                let trackerRep = imageCache.loadTrackerImage(for: trackerOwner)
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
                    Text(trackerDomain)
                        .daxBodyRegular()
                        .foregroundColor(.infoText)
                }
                .toggleStyle(SwitchToggleStyle(tint: .toggleTint))
                .onChange(of: isBlocking) { value in
                    onToggleTracker(trackerDomain, value)
                }
            }
            .padding(.horizontal)
            .frame(height: Const.Size.standardCellHeight)
            
            if showDivider {
                Divider()
                    .padding(.leading, Const.Size.dividerPadding)
            }
        }
    }
}

private enum Const {
    enum Size {
        static let standardCellHeight: CGFloat = 44
        static let dividerPadding: CGFloat = 44
        static let iconWidth: CGFloat = 25
    }
}

private extension Color {
    static let infoText = Color("AppTPDomainColor")
    static let toggleTint = Color(designSystemColor: .accent)
}
