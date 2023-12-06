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
    @State var selectedTheme: ThemeName = .systemDefault
    @State var setIsPresentingAppIconView: Bool = false
    @State var selectedFireButtonAnimation: FireButtonAnimationType = .fireRising
    @State private var isFirstUpdate = true
    
    var body: some View {
        Section(header: Text("Appeareance")) {
            Picker("Theme", selection: $selectedTheme) {
                ForEach(ThemeName.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            NavigationLink(destination: AppIconSettingsViewControllerRepresentable(), isActive: $setIsPresentingAppIconView) {
                ImageCell(label: "App Icon", image: Image(uiImage: viewModel.state.appIcon.smallImage ?? UIImage()))
            }
            
            Picker("Fire Button Animation", selection: $selectedFireButtonAnimation) {
                ForEach(FireButtonAnimationType.allCases) { option in
                    Text(option.descriptionText).tag(option)
                }
            }
            
            /*
            RightDetailCell(label: "Text Size", value: "100%", action: viewModel.selectTextSize)
            RightDetailCell(label: "Address Bar Position", value: "Top", action: viewModel.selectBarPosition)
            */
        }
        
        .onAppear {
            selectedTheme = viewModel.state.appTheme
            selectedFireButtonAnimation = viewModel.state.fireButtonAnimation
            isFirstUpdate = true
        }
        
        .onChange(of: selectedTheme) { newValue in
            viewModel.setTheme(theme: newValue)
        }
        
        .onChange(of: selectedFireButtonAnimation) { newValue in
            if isFirstUpdate {
                isFirstUpdate = false
                viewModel.setFireButtonAnimation(newValue, showAnimation: false)
            } else {
                viewModel.setFireButtonAnimation(newValue)
            }
        }
        
    }
}

struct AppIconSettingsViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = AppIconSettingsViewController

    class Coordinator {
        var parentObserver: NSKeyValueObservation?
    }

    func makeUIViewController(context: Self.Context) -> AppIconSettingsViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "AppIcon") as! AppIconSettingsViewController
        context.coordinator.parentObserver = viewController.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.title = vc.title
        })
        return viewController
    }

    func updateUIViewController(_ uiViewController: AppIconSettingsViewController, context: Context) {}

    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}
