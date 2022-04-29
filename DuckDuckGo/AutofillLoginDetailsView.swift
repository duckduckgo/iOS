//
//  AutofillLoginDetailsView.swift
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

@available(iOS 14.0, *)
struct AutofillLoginDetailsView: View {
    @State var text: String = ""
    @State var isOnEditMode = false
    @ObservedObject var viewModel: AutofillLoginDetailsViewModel
    
    var body: some View {
        List {
            Section {
                Text("Test")
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Username")
                        .bold()
                    TextField("", text: $viewModel.username)
                }
                
                VStack(alignment: .leading) {
                    Text("Password")
                        .bold()
                    TextField("", text: $viewModel.password)
                    
                }
            }
            
            Section {
                Text("Test2")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(isOnEditMode ? "Edit Login" : "Login")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                if isOnEditMode {
                    Button("Save") {
                        print("Save Pressed")
                        isOnEditMode.toggle()
                        viewModel.save()
                    }
                } else {
                    Button("Edit") {
                        print("Edit Pressed")
                        isOnEditMode.toggle()
                    }
                }
            }
        }
    }
}

#warning("Fix preview with protocol")
//@available(iOS 14.0, *)
//struct AutofillLoginDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AutofillLoginDetailsView()
//    }
//}
