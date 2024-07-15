//
//  HomeViewController+DaxDialogs.swift
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
import UIKit
import SwiftUI

extension HomeViewController {

    func showNextDaxDialog(spec: DaxDialogs.HomeScreenSpec) {

        guard !isShowingDax else { return }
        guard let daxDialogViewController = daxDialogViewController else { return }
        collectionView.isHidden = true
        daxDialogContainer.isHidden = false
        daxDialogContainer.alpha = 0.0

        daxDialogViewController.loadViewIfNeeded()
        daxDialogViewController.message = spec.message
        daxDialogViewController.accessibleMessage = spec.accessibilityLabel

        view.addGestureRecognizer(daxDialogViewController.tapToCompleteGestureRecognizer)

        daxDialogContainerHeight.constant = daxDialogViewController.calculateHeight()
        hideLogo()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.4, animations: {
                self.daxDialogContainer.alpha = 1.0
            }, completion: { _ in
                self.daxDialogViewController?.start()
            })
        }

        configureCollectionView()
    }

    func showNextDaxDialogNew(spec: DaxDialogs.HomeScreenSpec, factory: any NewTabDaxDialogProvider) {
        dismissHostingController()
        let daxDialogView = AnyView(factory.createDaxDialog(for: spec, onDismiss: dismissHostingController))
        hostingController = UIHostingController(rootView: daxDialogView)
        guard let hostingController else { return }
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hideLogo()
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        configureCollectionView()
    }

    private func dismissHostingController() {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        delegate?.home(self, didRequestHideLogo: false)
    }
}
