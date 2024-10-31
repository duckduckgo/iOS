//
//  TabViewController+TextZoomEditor.swift
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

import UIKit
import Common

extension TabViewController {

    func showTextZoomAdjustment() {
        guard let domain = TLD().eTLDplus1(webView.url?.host) else { return }
        let controller = TextZoomController(
            domain: domain,
            storage: domainTextZoomStorage,
            defaultTextZoom: appSettings.defaultTextZoomLevel
        )

        controller.modalPresentationStyle = .formSheet
        if #available(iOS 16.0, *) {
            controller.sheetPresentationController?.detents = [.custom(resolver: { _ in
                return 152
            })]

            controller.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = false
            controller.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
            controller.sheetPresentationController?.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            controller.sheetPresentationController?.detents = [.medium()]
        }

        present(controller, animated: true)
    }

}
