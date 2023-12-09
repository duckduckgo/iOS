//  SettingsAppeareanceView.swift
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
                                   selectedOption: viewModel.themeBinding)
            
            let image = Image(uiImage: viewModel.state.appIcon.smallImage ?? UIImage())
            SettingsCellView(label: "App Icon",
                             action: { viewModel.presentLegacyView(.appIcon ) },
                             accesory: .image(image),
                             asLink: true,
                             disclosureIndicator: true)
            
            SettingsPickerCellView(label: "Fire Button Animation",
                                   options: FireButtonAnimationType.allCases,
                                   selectedOption: viewModel.fireButtonAnimationBinding)
             
            if viewModel.shouldShowTextSizeCell {
                SettingsCellView(label: "Text Size",
                                 action: { viewModel.presentLegacyView(.textSize) },
                                 accesory: .rightDetail("\(viewModel.state.textSize)%"),
                                 asLink: true)
            }
            
            if viewModel.shouldShowAddressBarPositionCell {
                SettingsPickerCellView(label: "Address Bar Position",
                                       options: AddressBarPosition.allCases,
                                       selectedOption: viewModel.addressBarPositionBinding)
            }
            
            
        }
    
        
    }
}
