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
import DesignResourcesKit

#if APP_TRACKING_PROTECTION

struct AppTPHomeView: View {
    
    @ObservedObject var viewModel: AppTPHomeViewModel
    
    var countText: some View {
        Group {
            Text(UserText.appTPHomeBlockedPrefix)
            + Text(UserText.appTPHomeBlockedCount(countString: viewModel.blockCount))
                .fontWeight(.semibold)
            + Text(UserText.appTPHomeBlockedSuffix)
        }
        .foregroundColor(Color.fontColor)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.leading)
        .daxSubheadRegular()
    }
    
    var disabledText: some View {
        Group {
            Text(UserText.appTPHomeDisabledPrefix)
                .fontWeight(.semibold)
            + Text(UserText.appTPHomeDisabledSuffix)
        }
        .foregroundColor(Color.fontColor)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.leading)
        .daxSubheadRegular()
    }
    
    var image: some View {
        viewModel.appTPEnabled
            ? Image("AppTPHomeEnabled")
                .resizable()
            : Image("AppTPHomeDisabled")
                .resizable()
    }
    
    var body: some View {
        HStack(spacing: Const.Spacing.imageAndTitle) {
            if viewModel.appTPEnabled {
                countText
            } else {
                disabledText
            }
            
            Spacer()
            
            image
                .frame(width: 48, height: 48)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: Const.Radius.corner)
                        .fill(Color.background)
                        .shadow(color: Color.shadow,
                                radius: Const.Radius.shadow,
                                x: 0,
                                y: Const.Offset.shadowVertical))
        .onTapGesture {
            viewModel.showAppTPInSettings()
        }
    }
}

private extension Color {
    static let background = Color(designSystemColor: .surface)
    static let shadow = Color("HomeMessageShadowColor")
    static let fontColor = Color("AppTPDomainColor")
}

private enum Const {
    enum Radius {
        static let shadow: CGFloat = 3
        static let corner: CGFloat = 8
    }
    
    enum Spacing {
        static let imageAndTitle: CGFloat = 4
        static let lineHeight: CGFloat = 20
    }
    
    enum Offset {
        static let shadowVertical: CGFloat = 2
    }
}

#endif
