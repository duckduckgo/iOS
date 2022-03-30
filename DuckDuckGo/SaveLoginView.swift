//
//  SaveLoginView.swift
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

struct SaveLoginView: View {
    var body: some View {
        VStack {
            headerView
                .padding(.top, 5)
            contentView
        }
    }
    
    private var contentView: some View {
        GeometryReader { geometry in
            
            VStack {
                Text("Do you want DuckDuckGo to save your Login?")
                    .font(Const.Fonts.title)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 17)
                
                Text("Logins are stored securely on this device only, and can be managed from the Autofill menu in Settings.")
                    .font(Const.Fonts.subtitle)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
                
                buttonsStack
                
                Spacer()
            }.padding(.horizontal, geometry.size.width * 0.12)
        }
    }
    
    private var headerView: some View {
        ZStack {
            HStack {
                Image(systemName: "globe")
                Text("blablala.com")
                    .font(Const.Fonts.titleCaption)
            }
            HStack {
                Spacer()
                closeButton
            }
        }
    }
    
    private var closeButton: some View {
           Button {
           } label: {
               Image(systemName: "xmark")
                   .frame(width: 13, height: 13)
                   .foregroundColor(.primary)
           }
           .frame(width: 44, height: 44)
           .contentShape(Rectangle())
    }
    
    private var buttonsStack: some View {
        VStack {
            Button {
                
            } label: {
                Text("Save Login")
                    .font(Const.Fonts.CTA)
                    .foregroundColor(Const.Colors.CTAPrimaryForeground)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight)
                    .background(Const.Colors.CTAPrimaryBackground)
                    .foregroundColor(.primary)
                    .cornerRadius(Const.CornerRadius.CTA)
            }
            
            Button {
                
            } label: {
                Text("Not Now")
                    .font(Const.Fonts.CTA)
                    .foregroundColor(Const.Colors.CTASecondaryForeground)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight)
                    .background(Const.Colors.CTASecondaryBackground)
                    .foregroundColor(.primary)
                    .cornerRadius(Const.CornerRadius.CTA)
            }
        }
    }
}

struct SaveLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SaveLoginView()
    }
}

private enum Const {
    enum Fonts {
        static let title = Font.system(size: 20).weight(.semibold)
        static let subtitle = Font.system(size: 13.0)
        static let updatedInfo = Font.system(size: 16)
        static let titleCaption = Font.system(size: 13)
        static let CTA = Font(UIFont.boldAppFont(ofSize: 16))
        
    }
    enum CornerRadius {
        static let CTA: CGFloat = 12
    }
    
    enum Colors {
        static let CTAPrimaryBackground = Color("CTAPrimaryBackground")
        static let CTASecondaryBackground = Color("CTASecondaryBackground")
        static let CTAPrimaryForeground = Color("CTAPrimaryForeground")
        static let CTASecondaryForeground = Color("CTASecondaryForeground")
        
    }
    
    enum Size {
        static let CTAButtonCornerRadius: CGFloat = 12
        static let CTAButtonMaxHeight: CGFloat = 50
    }
}

extension Color {
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
}
