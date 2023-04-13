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
import SVGView

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
                SVGView(data: imageCache.loadTrackerImage(for: tracker.trackerOwner))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                
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
        static let sectionHeader = UIFont.semiBoldAppFont(ofSize: 15)
        static let info = UIFont.appFont(ofSize: 16)
    }
    
    enum Size {
        static let cornerRadius: CGFloat = 12
        static let sectionIndentation: CGFloat = 16
        static let sectionHeaderBottom: CGFloat = 6
        static let standardCellHeight: CGFloat = 44
    }
}

private extension Color {
    static let infoText = Color("AppTPDomainColor")
    static let cellBackground = Color("AppTPCellBackgroundColor")
    static let viewBackground = Color("AppTPViewBackgroundColor")
    static let toggleTint = Color("AppTPToggleColor")
}
