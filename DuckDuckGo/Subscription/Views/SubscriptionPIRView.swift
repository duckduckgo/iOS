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

#if SUBSCRIPTION
import SwiftUI
import Foundation
import DesignResourcesKit

@available(iOS 15.0, *)
struct SubscriptionPIRView: View {
        
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SubscriptionPIRViewModel()
    @State private var shouldShowNavigationBar = false
    
    enum Constants {
        static let daxLogo = "Home"
        static let daxLogoSize: CGFloat = 24.0
        static let empty = ""
        static let navButtonPadding: CGFloat = 20.0
    }
    
    var body: some View {
        NavigationView {
            baseView
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    dismissButton
                }
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(Constants.daxLogo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.daxLogoSize, height: Constants.daxLogoSize)
                        Text(viewModel.viewTitle).daxBodyRegular()
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            
            .onAppear(perform: {
                setUpAppearances()
                viewModel.initializeView()
            })
        }.tint(Color(designSystemColor: .textPrimary))
    }
    
    private var baseView: some View {
        VStack(alignment: .center) {
          Spacer()
          Spacer()
            Image("PersonalInformationHero")
                .aspectRatio(contentMode: .fill)
            VStack {
                Text("Activate Privacy Pro on desktop to set up Personal Information Removal")
                   .daxTitle2()
                   .multilineTextAlignment(.center)
                   .padding(.horizontal, 40)
                   .foregroundColor(Color(designSystemColor: .textPrimary))
                   .padding(.bottom, 20)
                Text("In the DuckDuckGo browser for desktop, go to Settings > Privacy Pro and click I Have a Subscription to get started.")
                    .daxBodyRegular()
                    .padding(.horizontal, 20)
                   .multilineTextAlignment(.center)
                   .padding(.horizontal, 20)
            }
            Spacer()
            VStack {
                macOSButton
                windowsButton
            }.padding(.bottom, 30)
        }.background(Image("SubscriptionBackground").resizable())
    }
    
    @ViewBuilder
    private var windowsButton: some View {
        Button(action: {}, label: {
            Text("Windows")
                .padding()
                .foregroundColor(Color(designSystemColor: .textPrimary))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(designSystemColor: .textPrimary), lineWidth: 1)
                        
                )
        })
    }
    
    @ViewBuilder
    private var macOSButton: some View {
        Button(action: {}, label: {
            HStack {
                Image(systemName: "applelogo")
                Text("macOS")
            }
            .padding()
            .foregroundColor(Color(designSystemColor: .textPrimary))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(designSystemColor: .textPrimary), lineWidth: 1)
            )
        })
    }
    
    @ViewBuilder
    private var dismissButton: some View {
        Button(action: { dismiss() }, label: { Text(UserText.subscriptionCloseButton) })
        .padding(Constants.navButtonPadding)
        .contentShape(Rectangle())
        .tint(Color(designSystemColor: .textPrimary))
    }
    
    
    private func setUpAppearances() {
        let navAppearance = UINavigationBar.appearance()
        navAppearance.backgroundColor = UIColor(designSystemColor: .surface)
        navAppearance.barTintColor = UIColor(designSystemColor: .surface)
        navAppearance.shadowImage = UIImage()
        navAppearance.tintColor = UIColor(designSystemColor: .textPrimary)
    }
}
#endif


struct SubscriptionPIRView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            SubscriptionPIRView()
        }
    }
}
