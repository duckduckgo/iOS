//
//  RemoveDeviceView.swift
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
import DuckUI
import DesignResourcesKit

struct RemoveDeviceView: View {

    @ObservedObject var model: RemoveDeviceViewModel

    @Environment(\.presentationMode) var presentation

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(model.imageName)

                Text(UserText.removeDeviceTitle)
                    .daxTitle1()

                Text(UserText.removeDeviceMessage(model.device.name))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .daxBodyRegular()
            }
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text(UserText.cancelButton)
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        model.remove()
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text(UserText.removeDeviceButton)
                            .foregroundColor(.red)
                    }
                }
            }
        }

    }

}
