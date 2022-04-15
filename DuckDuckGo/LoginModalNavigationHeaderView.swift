//
//  LoginModalNavigationHeaderView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

struct LoginModalNavigationHeaderView: View {
    let title: String
    var didClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.headerIconBackgroundCornerRadius)
                        .foregroundColor(.secondaryBackground)
                        .frame(width: Constants.headerIconBackgroundSize, height: Constants.headerIconBackgroundSize)
                    Image(Constants.headerIconImageName)
                        .foregroundColor(.primary)
                        .frame(width: Constants.headerIconSize, height: Constants.headerIconSize)
                }
                
                Text(title)
                    .foregroundColor(.black)
                    .font(.boldTitle)
                
                Spacer()
                
                Button {
                    didClose()
                } label: {
                    Image(systemName: Constants.closeButtonImageName)
                        .frame(width: Constants.closeButtonImageSize, height: Constants.closeButtonImageSize)
                        .foregroundColor(.closeButton)
                }
                .frame(width: Constants.closeButtonSize, height: Constants.closeButtonSize)
                .padding(.trailing, Constants.closeButtonImageOffset)
                .contentShape(Rectangle())      
            }.padding()
                .frame(height: Constants.headerHeight)
            Divider()
        }
        
    }
}

// MARK: - Constants

private extension Font {
    static let boldTitle = Font(uiFont: UIFont.boldAppFont(ofSize: 17))
}

private extension Color {
    static let closeButton = Color("CTAPrimaryColor")
    static let secondaryBackground = Color("FormSecondaryBackgroundColor")
}

private struct Constants {
    static let headerHeight: CGFloat = 72
    static let closeButtonImageSize: CGFloat = 13
    static let headerIconSize: CGFloat = 22
    static let headerIconBackgroundCornerRadius: CGFloat = 8
    static let headerIconBackgroundSize: CGFloat = 44
    static let closeButtonSize: CGFloat = 44
    static let closeButtonImageOffset: CGFloat = -10
    static let headerIconImageName = "Key"
    static let closeButtonImageName = "xmark"
}

// MARK: - Preview

struct LoginModalNavigationHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoginModalNavigationHeaderView(title: "Save Email and Password?", didClose: {})
    }
}
