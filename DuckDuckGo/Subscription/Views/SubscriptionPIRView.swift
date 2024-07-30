//
//  SubscriptionPIRView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import Foundation
import DesignResourcesKit
import DuckUI

struct SubscriptionPIRView: View {
        
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = SubscriptionPIRViewModel()
    @State private var isShowingWindowsView = false
    @State private var isShowingMacView = false
    
    enum Constants {
        static let empty = ""
        static let navButtonPadding: CGFloat = 20.0
        static let lightMask: [Color] = [Color.init(0xFFFFFF, alpha: 0), Color.init(0xFFFFFF, alpha: 0)]
        static let lightColors = [Color.init(0xF9F1F4), Color.init(0xF1F0FF)]
        static let darkMask = [Color.init(0x2F2F2F, alpha: 0), Color.init(0x2F2F2F, alpha: 1)]
        static let darkColors = [Color.init(0x3C184E), Color.init(0x3F1844), Color.init(0x3B1A36)]
        static let titleMaxWidth = 200.0
        static let headerPadding = 5.0
        static let generalSpacing = 20.0
        static let cornerRadius = 10.0
        static let windowsIcon = "Platform-Windows-16-subscriptions"
        static let macOSIcon = "Platform-Apple-16-subscriptions"
    }
    
    var body: some View {
        ZStack {
            gradientBackground
            ScrollView {
                VStack {
                    baseView
                        .frame(maxWidth: 600)
                }
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                DaxLogoNavbarTitle()
            }
        }
        .onFirstAppear {
            viewModel.onFirstAppear()
        }
    }
        
    
    private var gradientBackground: some View {
        ZStack {
            LinearGradient(colors: colorScheme == . dark ? Constants.darkColors : Constants.lightColors,
                           startPoint: .top,
                           endPoint: .bottom)
            LinearGradient(colors: colorScheme == . dark ? Constants.darkMask : Constants.lightMask,
                           startPoint: .top,
                           endPoint: .bottom)
        }
    }
        
    private var baseView: some View {
        VStack(alignment: .center, spacing: Constants.generalSpacing) {
            Image("PersonalInformationHero")
                .aspectRatio(contentMode: .fill)
                .padding(.top, Constants.generalSpacing)
            VStack {
                Text(UserText.subscriptionPIRHeroText)
                   .daxTitle2()
                   .multilineTextAlignment(.center)
                   .padding(.horizontal, Constants.generalSpacing*2)
                   .foregroundColor(Color(designSystemColor: .textPrimary))
                   .padding(.bottom, Constants.generalSpacing)
                attributedDescription
                    .padding(.horizontal, Constants.generalSpacing)
                   .multilineTextAlignment(.center)
                   .padding(.horizontal, Constants.generalSpacing)
            }
            Spacer()
            Spacer()
            VStack {
                macOSButton
                windowsButton
            }
            .padding(.bottom, Constants.generalSpacing*2)
            
        }
    }
        
    private var attributedDescription: some View {
        let baseStringFormat = UserText.subscriptionPIRHeroDetail
        let insertString1 = UserText.subscriptionPIRHeroDesktopMenuLocation
        let insertString2 = UserText.subscriptionPIRHeroDesktopMenuItem

        let highlightFont = Font(uiFont: .daxBodyBold())
        
        let fullString = String(format: baseStringFormat, insertString1, insertString2)
        var attributedString = AttributedString(fullString)
        attributedString.font = .daxBodyRegular()
                
        if let range1 = attributedString.range(of: insertString1) {
            attributedString[range1].font = highlightFont
        }

        if let range2 = attributedString.range(of: insertString2) {
            attributedString[range2].font = highlightFont}

        return Text(attributedString)
    }
    
    @ViewBuilder
    private var windowsButton: some View {
        NavigationLink(destination: DesktopDownloadView(viewModel: .init(platform: .windows)),
         isActive: $isShowingWindowsView) {
            HStack {
                Image(Constants.windowsIcon)
                Text(UserText.subscriptionPIRWindows)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(Color(designSystemColor: .accent))
            .daxButton()
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color(designSystemColor: .accent), lineWidth: 1)
                
            )
            .padding(.horizontal, Constants.generalSpacing)
        }
    }
    
    @ViewBuilder
    private var macOSButton: some View {
         NavigationLink(destination: DesktopDownloadView(viewModel: .init(platform: .mac)),
                       isActive: $isShowingMacView) {
            HStack {
                Image(Constants.macOSIcon)
                Text(UserText.subscriptionPIRMacOS)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(Color(designSystemColor: .accent))
            .daxButton()
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color(designSystemColor: .accent), lineWidth: 1)
                
            )
            .padding(.horizontal, Constants.generalSpacing)
         }
    }
    
    @ViewBuilder
    private var dismissButton: some View {
        Button(action: { dismiss() }, label: { Text(UserText.subscriptionCloseButton) })
        .padding(Constants.navButtonPadding)
        .contentShape(Rectangle())
        .daxBodyRegular()
        .tint(Color(designSystemColor: .textPrimary))
    }
}

// Commented out because CI fails if a SwiftUI preview is enabled https://app.asana.com/0/414709148257752/1206774081310425/f
// struct SubscriptionPIRView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionPIRView()
//    }
// }
