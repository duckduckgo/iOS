// TODO: Remove transition animation if showing a selected account//
//  GeneralSection.swift
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
import UIKit

struct SettingsAppeareanceView: View {
        
    @EnvironmentObject var viewModel: SettingsViewModel

    var body: some View {
        Section(header: Text("Appeareance")) {
            SettingsPickerCellView(label: "Theme",
                                   options: ThemeName.allCases,
                                   selectedOption: Binding(
                                        get: { viewModel.state.general.appTheme },
                                        set: { viewModel.setTheme($0) }
                                   ))
             
            NavigationLink(destination: LazyView(AppIconSettingsViewControllerRepresentable()),
                           isActive: $viewModel.isPresentingAppIconView) {
                let image = Image(uiImage: viewModel.state.general.appIcon.smallImage ?? UIImage())
                SettingsCellView(label: "App Icon",
                                 accesory: .image(image))
            }
             
            SettingsPickerCellView(label: "Fire Button Animation",
                                   options: FireButtonAnimationType.allCases,
                                   selectedOption: Binding(
                                        get: { viewModel.state.general.fireButtonAnimation },
                                        set: { viewModel.setFireButtonAnimation($0) }
                                   ))
             
            // The textsize settings view has a special behavior (detent adjustment) that requires access to a navigation controller
            // The current implementation will not work on top of the SwiftUI stack, so we need to push it via the UIKit Container
            if viewModel.shouldShowTextSizeCell {
                SettingsCellView(label: "Text Size",
                                 action: { viewModel.isPresentingTextSettingsView = true },
                                 accesory: .rightDetail("\(viewModel.state.general.textSize)%"),
                                 asLink: true)
            }
            
            if viewModel.shouldShowAddressBarPositionCell {
                SettingsPickerCellView(label: "Address Bar Position",
                                       options: AddressBarPosition.allCases,
                                       selectedOption: Binding(
                                            get: { viewModel.state.general.addressBarPosition },
                                            set: { viewModel.setAddressBarPosition($0) }
                                       ))
            }
            
            
        }
    
        
    }
}
