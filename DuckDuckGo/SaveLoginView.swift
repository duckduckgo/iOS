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
    @ObservedObject var loginViewModel: SaveLoginViewModel
    
    var body: some View {
        if #available(iOS 14.0, *) {
           mainView()
                .ignoresSafeArea()
        } else {
            mainView()
        }
    }
    
    private func mainView() -> some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
            
            VStack {
                LoginModalNavigationHeaderView(title: UserText.loginPlusFormSaveEmailPasswordTitle, didClose: {
                    loginViewModel.dismissLoginView()
                })
                
                SaveLoginFormView(loginViewModel: loginViewModel)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: Constants.formBackgroundCornerRadius)
                            .foregroundColor(Constants.formBackgroundColor)
                    )
                    .padding(.top)
                    .padding(.bottom)
                    .padding(.leading, Constants.formPadding)
                    .padding(.trailing, Constants.formPadding)
                
                footerCTA()
                    .padding(.leading, Constants.formPadding)
                    .padding(.trailing, Constants.formPadding)
                
                Spacer()
            }
        }
    }
    
    private func footerCTA() -> some View {
        HStack {
            Button {
                loginViewModel.dismissLoginView()
            } label: {
                Text("Not now")
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Constants.CTAButtonMaxHeight)
                    .background(Constants.cancelButtonColor)
                    .foregroundColor(.primary)
                    .cornerRadius(Constants.CTAButtonCornerRadius)
            }
            
            Button {
                loginViewModel.saveLogin()
            } label: {
                Text("Save")
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Constants.CTAButtonMaxHeight)
                    .background(Constants.saveButtonColor)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.CTAButtonCornerRadius)
            }
        }
    }
}

struct SaveLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SaveLoginView(loginViewModel: SaveLoginViewModel.preview).preferredColorScheme(.light)
        SaveLoginView(loginViewModel: SaveLoginViewModel.preview).preferredColorScheme(.dark)
    }
}

private struct Constants {
    static let formPadding: CGFloat = 45
    static let formBackgroundCornerRadius: CGFloat = 13
    static let CTAButtonCornerRadius: CGFloat = 12
    static let CTAButtonMaxHeight: CGFloat = 50
    static let saveButtonColor = Color("CTAPrimaryColor")
    static let cancelButtonColor = Color("FormSecondaryBackgroundColor")
    static let formBackgroundColor = Color("FormSecondaryBackgroundColor")
}
