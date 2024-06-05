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

    let title: String
    let image: String
    let leftButton: (title: String, action: () -> Void)
    let rightButton: (title: String, action: () -> Void)

    private var showAlert = false
    private lazy var alertView: AlertView = {
        AlertView(title: title,
                  image: image,
                  leftButton: leftButton,
                  rightButton: rightButton,
                  isVisible: Binding(get: { self.showAlert }, set: { self.showAlert = $0 })
        )
    }()
    private lazy var hostingController: UIHostingController<AlertView> = {
        let hostingController = UIHostingController(rootView: alertView)
        hostingController.view.backgroundColor = .clear
        return hostingController
    }()

    init(title: String,
         image: String,
         leftButton: (title: String, action: () -> Void),
         rightButton: (title: String, action: () -> Void)) {
        self.title = title
        self.image = image
        self.leftButton = leftButton
        self.rightButton = rightButton
    }

    func present(in viewController: UIViewController, animated: Bool) {
        showAlert = true

        guard let view = viewController.view else { return }
        viewController.addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: viewController)
        hostingController.view.alpha = 0.0

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.window!.centerYAnchor),
            hostingController.view.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40)
        ])

        if animated {
            UIView.animate(withDuration: 0.2) {
                self.hostingController.view.alpha = 1.0
            }
        } else {
            hostingController.view.alpha = 1.0
        }
    }

    func hide() {
        showAlert = false
        hostingController.willMove(toParent: nil)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()
    }

}
