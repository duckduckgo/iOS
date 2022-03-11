//
//  QuickLookPreviewView.swift
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

struct QuickLookPreviewView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let localFileURL: URL
    
    func makeUIViewController(context: Context) -> QuickLookContainerViewController {
        let controller = QuickLookContainerViewController(localFileURL: localFileURL)
        controller.onDoneButtonPressed = {
            presentationMode.wrappedValue.dismiss()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QuickLookContainerViewController, context: Context) {
        uiViewController.reloadData()
    }
}
