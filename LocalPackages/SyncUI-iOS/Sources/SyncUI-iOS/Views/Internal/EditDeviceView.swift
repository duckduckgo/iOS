//
//  EditDeviceView.swift
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

struct EditDeviceView: View {

    @ObservedObject var model: EditDeviceViewModel

    @Environment(\.presentationMode) var presentation

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("", text: $model.name)
                } header: {
                    Text(UserText.editDeviceHeader)
                }
            }
            .applyListStyle()
            .navigationTitle(UserText.editDeviceTitle(model.name))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text(UserText.cancelButton)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        model.save()
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text(UserText.doneButton)
                    }
                }
            }
        }

    }

}
