//
//  AppTPTrackerCell.swift
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
import Core
import DesignResourcesKit

struct AppTPTrackerCell: View {
    let trackerDomain: String
    let trackerOwner: String
    let trackerCount: Int32
    let trackerBlocked: Bool

    let trackerTimestamp: String?
    let trackerBucket: String
    let debugMode: Bool

    let imageCache: AppTrackerImageCache
    let showDivider: Bool
    
    func stringForTrackerTimestamp() -> String {
        let timeStr = trackerTimestamp ?? UserText.appTPJustNow
        
        if trackerBlocked {
            return UserText.appTPTrackerBlockedTimestamp(timeString: timeStr)
        } else {
            return UserText.appTPTrackerAllowedTimestamp(timeString: timeStr)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                AppTPActivityIconView(trackerImage: imageCache.loadTrackerImage(for: trackerOwner),
                                      blocked: trackerBlocked)

                VStack(alignment: .leading, spacing: Const.Size.rowSpacing) {
                    Text(trackerDomain)
                        .lineLimit(1)
                        .daxBodyRegular()
                        .foregroundColor(.trackerDomain)
                    
                    Text(UserText.appTPTrackingAttempts(count: trackerCount))
                        .font(Font(uiFont: Const.Font.trackerCount))
                        .foregroundColor(.trackerSize)
                    
                    Text(stringForTrackerTimestamp())
                        .font(Font(uiFont: Const.Font.trackerCount))
                        .foregroundColor(.trackerSize)

                    if debugMode {
                        Text("bucket: \(trackerBucket)")
                            .font(Font(uiFont: Const.Font.trackerCount))
                            .foregroundColor(.trackerSize)
                    }
                }
                
                Spacer()
                
                Image("DisclosureIndicator")
                    .resizable()
                    .frame(width: 7, height: 12)
                    .foregroundColor(Color.disclosureColor)
            }
            .padding(.horizontal, Const.Size.rowPadding)
            .frame(height: Const.Size.rowHeight)
            
            if showDivider {
                Divider()
                    .padding(.leading, Const.Size.dividerPadding)
            }
        }
    }
}

private enum Const {
    enum Font {
        static let trackerCount = UIFont.appFont(ofSize: 13)
    }
    
    enum Size {
        static let rowHeight: CGFloat = 78
        static let rowPadding: CGFloat = 16
        static let rowSpacing: CGFloat = 4
        static let dividerPadding: CGFloat = 62
    }
}

private extension Color {
    static let trackerDomain = Color("AppTPDomainColor")
    static let trackerSize = Color(designSystemColor: .textSecondary)
    static let cellBackground = Color(designSystemColor: .background)
    static let disclosureColor = Color("AppTPDisclosureColor")
}
