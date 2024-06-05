//
//  AlertViewPresenter.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation
import SwiftUI
import UIKit

final class AlertViewPresenter {

    private var showAlert = false

    func present() {
        let alertView = AlertView(
            question: "Do you want to continue?",
            onYes: { print("User selected Yes") },
            onNo: { print("User selected No") },
            isVisible: Binding(get: { self.showAlert }, set: { self.showAlert = $0 })
        )

        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }

        // Embed the SwiftUI view in a UIHostingController
        let hostingController = UIHostingController(rootView: alertView)
        hostingController.view.frame = window.bounds
        hostingController.view.backgroundColor = .clear

        // Add the hosting controller as a child
        window.rootViewController?.addChild(hostingController)
        window.addSubview(hostingController.view)
        hostingController.didMove(toParent: window.rootViewController)

        // Dismiss the alert after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showAlert = false
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }
    }

}
