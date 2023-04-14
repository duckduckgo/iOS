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

// Temporarily we are including this package to display SVGs embedded in the Privacy Dashboard package
// Once we have our own asset catalog of tracker network images we can remove this package.
import SVGView

struct AppTPTrackerCell: View {
    let trackerDomain: String
    let trackerOwner: String
    let trackerCount: Int32
    let trackerBlocked: Bool

    let trackerTimestamp: String
    let trackerBucket: String
    let debugMode: Bool

    let imageCache: AppTrackerImageCache
    let showDivider: Bool
    
    func stringForTrackerTimestamp() -> String {
        var timeStr = trackerTimestamp
        if timeStr == "0" {
            timeStr = UserText.appTPJustNow
        }
        
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

                VStack(alignment: .leading, spacing: 4) {
                    Text(trackerDomain)
                        .font(Font(uiFont: Const.Font.trackerDomain))
                        .foregroundColor(.trackerDomain)
                    
                    Text(UserText.appTPTrackingAttempts(count: "\(trackerCount)"))
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
                
                Image(systemName: "chevron.forward")
                    .resizable()
                    .frame(width: 7, height: 12)
                    .foregroundColor(Color.disclosureColor)
            }
            .padding(.horizontal, 16)
            .frame(height: Const.Size.rowHeight)
            
            if showDivider {
                Divider()
            }
        }
    }
}

private enum Const {
    enum Font {
        static let trackerDomain = UIFont.appFont(ofSize: 16)
        static let trackerCount = UIFont.appFont(ofSize: 13)
    }
    
    enum Size {
        static let rowHeight: CGFloat = 78
    }
}

private extension Color {
    static let trackerDomain = Color("AppTPDomainColor")
    static let trackerSize = Color("AppTPCountColor")
    static let cellBackground = Color("AppTPCellBackgroundColor")
    static let disclosureColor = Color("AppTPDisclosureColor")
}
