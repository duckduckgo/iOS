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
    
    var body: some View {
        HStack {
            Text(text)
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
    
    var body: some View {
        HStack {
            TextField(UserText.loginPlusFormUsernamePlaceholder, text: $username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
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
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(UserText.loginPlusFormPasswordPlaceholder, text: $password)
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

struct SaveLoginCells_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SaveLoginWebsiteCell(text: "www.duck.com", image: Image(systemName: "globe"))
            SaveLoginUsernameCell(username: .constant("Dax"))
            SaveLoginPasswordCell(isSecure: false, password: .constant("LV-426"))
            SaveLoginPasswordCell(isSecure: true, password: .constant("LV-426"))
        }.padding()
    }
}
