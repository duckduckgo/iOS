//
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

struct SettingsGeneralView: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @State var isPresentingAddToDockView: Bool = false
    @State var isPresentingAddWidgetView: Bool = false
    
    var body: some View {
        Section {
            PlainCell(label: "Set as Default Browser", action: viewModel.setAsDefaultBrowser)
            PlainCell(label: "Add App to Your Dock", action: {
                { viewModel.setIsPresentingAddToDockView(true) }()
            })
            NavigationLink(destination: WidgetEducationView(), isActive: $isPresentingAddWidgetView) {
                PlainCell(label: "Add Widget to Home Screen", action: { viewModel.setIsPresentingAddWidgetView(true) })
            }
        }
        
        .onChange(of: viewModel.state.isPresentingAddToDockView) { newValue in
            isPresentingAddToDockView = newValue
        }
        
        .onChange(of: isPresentingAddToDockView) { newValue in
            viewModel.setIsPresentingAddToDockView(newValue)
        }
        
        .onChange(of: isPresentingAddWidgetView) { newValue in
            viewModel.setIsPresentingAddWidgetView(newValue)
        }
        
        // Modal View
        .fullScreenCover(isPresented: $isPresentingAddToDockView) {
            HomeRowInstructionsViewControllerRepresentable()
        }
    }
 
}

struct HomeRowInstructionsViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = HomeRowInstructionsViewController

    class Coordinator {
        var parentObserver: NSKeyValueObservation?
    }

    func makeUIViewController(context: Self.Context) -> HomeRowInstructionsViewController {
        let storyboard = UIStoryboard(name: "HomeRow", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "instructions") as! HomeRowInstructionsViewController
        context.coordinator.parentObserver = viewController.observe(\.parent, changeHandler: { vc, _ in
            vc.parent?.title = vc.title
        })
        return viewController
    }

    func updateUIViewController(_ uiViewController: HomeRowInstructionsViewController, context: Context) {}

    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}
