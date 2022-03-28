//
//  SaveLoginViewCells.swift
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

struct SaveLoginWebsiteCell: View {
    let text: String
    let image: Image
    let disabled: Bool
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(disabled ? .gray : .textPrimary)
                .font(.bold)
                .disabled(disabled)
            
            Spacer()
            image
                .resizable()
                .frame(width: 20, height: 20)
                .cornerRadius(3)
        }
    }
}

struct SaveLoginUsernameCell: View {
    @Binding var username: String
    let disabled: Bool

    var body: some View {
        HStack {
            TextField(UserText.loginPlusFormUsernamePlaceholder, text: $username)
                .font(.normal)
                .foregroundColor(disabled ? .gray : .textPrimary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .disabled(disabled)

            Spacer()
        }
    }
}

struct SaveLoginPasswordCell: View {
    @State var isSecure: Bool = true
    @Binding var password: String
    
    var body: some View {
        HStack {
            if isSecure {
                SecureField(UserText.loginPlusFormPasswordPlaceholder, text: $password)
                    .foregroundColor(.textPrimary)
                    .font(.normal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(UserText.loginPlusFormPasswordPlaceholder, text: $password)
                    .foregroundColor(.textPrimary)
                    .font(.normal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Spacer()
            
            Button {
                isSecure.toggle()
            } label: {
                if isSecure {
                    Image("ShowPassword")
                } else {
                    Image("HidePassword")
                }
            }
            .frame(width: 44, height: 44)
            .padding(.trailing, -12)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Constants

private extension Font {
    static let bold = Font(uiFont: UIFont.boldAppFont(ofSize: 16))
    static let normal = Font(uiFont: UIFont.appFont(ofSize: 16))
}

// MARK: - Preview

struct SaveLoginCells_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SaveLoginWebsiteCell(text: "www.duck.com", image: Image(systemName: "globe"), disabled: false)
            SaveLoginUsernameCell(username: .constant("Dax"), disabled: false)
            SaveLoginPasswordCell(isSecure: false, password: .constant("LV-426"))
            SaveLoginPasswordCell(isSecure: true, password: .constant("LV-426"))
        }.padding()
    }
}
