//
//  DuckPlayerModalPresenter.swift
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

struct DuckPlayerModalPresenter {

    enum PresentationContext {
        case SERP, youtube
    }
    
    var context: PresentationContext = .SERP
    
    func presentDuckPlayerFeatureModal(on viewController: UIViewController) {
        let hostingController = createHostingController()
        configurePresentationStyle(for: hostingController, on: viewController)
        viewController.present(hostingController, animated: true, completion: nil)
        
        hostingController.rootView.dismisPresentation = {
            viewController.dismiss(animated: true)
        }
    }

    private func createHostingController() -> UIHostingController<DuckPlayerFeaturePresentationView> {
        let duckPlayerFeaturePresentationView = DuckPlayerFeaturePresentationView(context: context)
        let hostingController = UIHostingController(rootView: duckPlayerFeaturePresentationView)
        hostingController.modalPresentationStyle = .pageSheet
        hostingController.modalTransitionStyle = .coverVertical
        return hostingController
    }

    private func configurePresentationStyle(for hostingController: UIHostingController<DuckPlayerFeaturePresentationView>, on viewController: UIViewController) {
        if let sheet = hostingController.presentationController as? UISheetPresentationController {

            if #available(iOS 16.0, *) {
                let targetSize = getTargetSizeForPresentationView(on: viewController)
                sheet.detents = [.custom { _ in targetSize.height }]
            } else {
                sheet.detents = [.large()]

            }
        }
    }

    @available(iOS 16.0, *)
    private func getTargetSizeForPresentationView(on viewController: UIViewController) -> CGSize {
        let duckPlayerFeaturePresentationView = DuckPlayerFeaturePresentationView(context: context)
        let sizeHostingController = UIHostingController(rootView: duckPlayerFeaturePresentationView)
        sizeHostingController.view.translatesAutoresizingMaskIntoConstraints = false

        viewController.view.addSubview(sizeHostingController.view)
        NSLayoutConstraint.activate([
            sizeHostingController.view.widthAnchor.constraint(equalToConstant: viewController.view.frame.width)
        ])

        sizeHostingController.view.layoutIfNeeded()

        let targetSize = sizeHostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        sizeHostingController.view.removeFromSuperview()

        return targetSize
    }
}
