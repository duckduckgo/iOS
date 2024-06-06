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

    private enum Constants {

        static let animationDuration: Double = 0.2
        static let bottomPadding: Double = 28.0
        static let horizontalPadding: Double = 20.0
        static let maxWidth: Double = 358.0

    }

    let title: String
    let image: String
    let leftButton: (title: String, action: () -> Void)
    let rightButton: (title: String, action: () -> Void)

    private var showAlert = false
    private lazy var alertView: AlertView = {
        AlertView(title: title,
                  image: image,
                  leftButton: (leftButton.title, { [weak self] in self?.leftButton.action(); self?.hide() }),
                  rightButton: (rightButton.title, { [weak self] in self?.rightButton.action(); self?.hide() }),
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
        guard let view = viewController.view, let window = view.window else { return }

        showAlert = true

        viewController.addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: viewController)
        hostingController.view.alpha = 0.0

        let alertViewWidth = min(window.frame.width - 2 * Constants.horizontalPadding, Constants.maxWidth)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.bottomPadding),
            hostingController.view.widthAnchor.constraint(equalToConstant: alertViewWidth)

        ])

        if animated {
            UIView.animate(withDuration: Constants.animationDuration) {
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
